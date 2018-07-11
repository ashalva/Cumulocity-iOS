//
//  Session.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 27/09/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON
import SystemConfiguration

//generic type of response, which will hold the reference of the desired class
struct NetworkResponse<T> {
    //smart rest response for text values
    var rawValue: String?
    
    //values of desired object if server returns array of T
    let values: [T]?
    
    //value of desired object if server returns single T
    var value: T? {
        return values?.first
    }
    // server error, indicating different cases
    let error: NetworkError?
}

//all network errors that may occur in the app
enum NetworkError: Error {
    case noError
    case noInternet
    case forbidden
    case client
    case server
    case json
    case noData
    case timeout
    case notfound
    case wrongCredentials
    case notRegistered
}

//debug variable, if true printing the all responses returned from cumulocity
private let DEBUG_NETWORK_REQUESTS_WITH_BODY = true
//timeinterval for credentials request polling
private let POLLING_CREDENTIALS_SECS: TimeInterval = 3

class Session {
    
    static let STATUS_CODE_MISSING = 7708
    static let shared = Session()
    static var operationClientId: String?
    static var device: Device? = Device(json: JSON.null)
    static var registeredDevice: RegisteredDevice? = RegisteredDevice(json: JSON.null)
    static var credentials: Credentials? = Credentials(json: JSON.null)
    
    let links = Links()
    
    static let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    //constructing Alamofire session manager
    fileprivate lazy var the_mgr: Alamofire.SessionManager = {
        let cfg = URLSessionConfiguration.default
        cfg.httpCookieStorage = HTTPCookieStorage.shared
        cfg.timeoutIntervalForRequest = 10000000
        return Alamofire.SessionManager(configuration: cfg)
    }()
    
}

extension Session {
    //rest method, used by NetworkOperation.swift class
    //parameters:
    //type: rest type(post,get,put,delete) currently using only post,get
    //string: string url
    //parameters: json body
    //textParameters: text parameters for smartrest
    //headers: method headers
    //completion: callback executed whenever the server responds
    @discardableResult func restRequest<T: FromRemoteSource>(type: HTTPMethod, string: String, parameters: Parameters, textParameters: String?, headers: HTTPHeaders?, completion: @escaping (NetworkResponse<T>) -> Void) -> DataRequest? {
        let requestUrl = URL(string: string, relativeTo: links.restURL)!
        if type == .get {
            return netGet(from: requestUrl, headers: Headers.get(), responseHandler: completion)
        } else {
            return netPost(to: requestUrl, with: parameters, textParam: textParameters, headers: headers, responseHandler: completion)
        }
    }
    
    //post method
    //parameters:
    //path: url
    //parameters: json body
    //textParam: text parameters for smartrest
    //headers: method headers
    //responseHandler: callback executed whenever the server responds
    @discardableResult fileprivate
    func netPost<T: FromRemoteSource>( to path: URLConvertible
        , with parameters: Parameters? = nil
        , textParam: String? = nil
        , headers: HTTPHeaders? = nil
        , responseHandler: @escaping ((NetworkResponse<T>) -> Void)
        ) -> DataRequest? {
        
        return execute(.post, at: path, with: textParam == nil ? parameters : [:], encoding: textParam == nil ? JSONEncoding.default : textParam!, headers: headers, responseHandler: responseHandler)
    }
    
    //get method
    //parameters:
    //path: url
    //parameters: json body
    //textParam: text parameters for smartrest
    //headers: method headers
    //responseHandler: callback executed whenever the server responds
    @discardableResult fileprivate
    func netGet<T: FromRemoteSource>( from path: URLConvertible
        , with parameters: Parameters? = nil
        , encoding: ParameterEncoding = JSONEncoding.default
        , headers: HTTPHeaders? = nil
        , responseHandler: @escaping ((NetworkResponse<T>) -> Void)
        ) -> DataRequest? {
        return execute(.get, at: path, with: parameters, encoding: encoding, headers: headers, responseHandler: responseHandler)
    }
    
    //method executed by netPost or netGet
    //sending the request and getting the response
    @discardableResult private
    func execute<T: FromRemoteSource>(_ method: HTTPMethod
        , at url: URLConvertible
        , with parameters: Parameters? = nil
        , encoding: ParameterEncoding = JSONEncoding.default
        , headers: HTTPHeaders? = nil
        , responseHandler: @escaping ((NetworkResponse<T>) -> Void)
        ) -> DataRequest? {
        
        guard Session.isConnectedToNetwork() else {
            DispatchQueue.main.async() {
                responseHandler(NetworkResponse(rawValue: nil, values: nil,error: .noInternet))
            }
            return nil
        }
        
        let request = the_mgr.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        
        request.responseData() {
            response in
            
            let statusCode = response.response?.statusCode ?? Session.STATUS_CODE_MISSING
            self.handle(statusCode, data: response.data, networkError: response.result.error, completion: responseHandler)
        }
        
        return request
    }
    
    //method executed by execute() method
    //handling the response and calling callback
    internal func handle<T: FromRemoteSource>(_ statusCode: Int, data: Data?, networkError: Error? = nil, completion: (NetworkResponse<T>) -> Void) {
        var error: NetworkError?
        var values: [T]?
        var rawValue: String?
        
        defer {
            let response = NetworkResponse(rawValue: rawValue, values: values, error: error)
            completion(response)
        }
        
        if(DEBUG_NETWORK_REQUESTS_WITH_BODY){
            if let data = data, let string = String(data: data, encoding: .utf8) {
                debugPrint("### HTTP RESPONSE BODY <-- \(string)")
            }
        }
        
        guard let data = data else {
            return
        }
        
        if statusCode == 404 {
            error = .notfound
        }
        
        if statusCode == 808 {
            error = .notRegistered
        }
        
        if statusCode == 401 {
            error = .wrongCredentials
        }
        
        if statusCode == 200 {
            error = .noError
        }
        
        if let string = String(data: data, encoding: .utf8) {
            rawValue = string
        }
        
        if T.self is FromRawJSON.Type {
            let json = JSON(data: data)
            if let result = T(raw: json) {
                values = [result]
            } else {
                error = .json
            }
            return
        }
    }

    //checking network connection
    fileprivate class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    
    //checking if device is registered
    class func isDeviceRegistered(callback: @escaping (Bool) -> Void) {
        let op = NetworkOperation(urlString: "\(Links.BASE_URL)/identity/externalIds/c8y_Serial/\(Device.externalId)", headers: Headers.get()) {
            (result: NetworkResponse<RegisteredDevice>) in
            
            guard let _ = result.value else {
                return
            }
            
            if result.error! == .noError {
                Session.registeredDevice = result.value
            }
            
            callback(result.error! == .noError)
        }
        operationQueue.addOperation(op)
    }
    
    //creating new device request, which request the credentials from the cumulocity
    func createNewDeviceRequest(callback: @escaping () -> Void) {
        let params = ["id": Device.getSerialNumber()]
        
        netPost(to: "\(Links.BASE_URL)/devicecontrol/newDeviceRequests", with: params, headers: Headers.credentialsHeaders()) {
            (result: NetworkResponse<RawResponse>) in
            self.getCredentials() {
                callback()
            }
        }
    }
    
    //polling function, after tenant accepts the credentials for the device
    //the method will get the temporary username + password
    func getCredentials(callback: @escaping () -> Void) {
        let params = ["id": Device.getSerialNumber()]
        
        netPost(to: "\(Links.BASE_URL)/devicecontrol/deviceCredentials", with: params, headers: Headers.credentialsHeaders()) {
            (result: NetworkResponse<Credentials>) in
            
            if result.error == nil {
                callback()
                Session.credentials = result.value
                return
            }
            
            self.scheduleNextPoll(callback: callback)
        }
    }
    
    func scheduleNextPoll(callback: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + POLLING_CREDENTIALS_SECS) {
            self.getCredentials() {
                callback()
            }
        }
    }
    
    //checking if the credentials are correct
    class func credentialsCorrect(callback: @escaping (Bool) -> Void) {
        let op = NetworkOperation(urlString: "\(Links.BASE_URL)/identity/externalIds/c8y_Serial/\(Device.externalId)") {
            (result: NetworkResponse<RegisteredDevice>) in
            
            guard let _ = result.value else {
                return
            }

            callback(result.error! != .wrongCredentials)
        }
        operationQueue.addOperation(op)
    }
    
    //creating the device in cumulocity
    //parameters: externalId - unique string for device
    func createDevice(externalId: String, callback: @escaping (Bool) -> Void) {
        
        let params: Parameters = ["name": "\(externalId)",
                                  "type":"c8y_SensorPhone",
                                  "c8y_Hardware" : ["model": Device.getModel(),
                                    "serialNumber" : Device.getSerialNumber(),
                                    "revision" : Device.getSystemVersion() ],
                                  "c8y_IsDevice" : [],
                                  "com_cumulocity_model_Agent" : [],
                                  "c8y_SupportedOperations": [ "c8y_Restart", "c8y_Vibrate" ]
                                  ]
        
        netPost(to: "\(Links.BASE_URL)/inventory/managedObjects", with: params, headers: Headers.post()) {
            (result: NetworkResponse<Device>) in
            
            Session.device = result.value
            
            callback(result.error == nil || result.error == .noError)
        }
    }
    
    //before subscribing on operation we should make the handshake to cumulocity
    func handShake(callback: @escaping () -> Void) {
       var headers = Headers.authHeader()
        headers["X-Id"] = "operations"
        
        netPost(to: "\(Links.BASE_URL)/devicecontrol/notifications", with: [:],  textParam: "80", headers: headers) {
            (result: NetworkResponse<RawResponse>) in
            if let rv = result.rawValue {
                Session.operationClientId = rv.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
                callback()
            }
        }
    }
    
    //after handshke we are subscribing on the operations
    func subscribe(callback: @escaping () -> Void) {
        let params = [
            "channel" : "/meta/subscribe",
            "subscription": "/operations/\(Session.registeredDevice?.managedObject.id ?? "")",
            "clientId": Session.operationClientId ?? ""
        ]
        
        netPost(to: "\(Links.BASE_URL)/cep/realtime", with:params, headers: Headers.post()) {
            (result: NetworkResponse<Subscribtion>) in
            guard let sub = result.value else {
                return
            }
            
            if let suc = sub.successfull, suc {
                callback()
            } else {
                print(Localisation.local("error.subscription.operation"))
            }
        }
    }
    
    //method which is waiting for operations to be sent from cumulocity
    func longPoll(callback: @escaping () -> Void) {
        let params = [
            "channel" : "/meta/connect",
            "connectionType": "long-polling",
            "clientId": Session.operationClientId ?? ""
        ]
        
        netPost(to: "\(Links.BASE_URL)/cep/realtime", with:params, headers: Headers.post()) {
            (result: NetworkResponse<Operations>) in 
            guard let operation = result.value else {
                return
            }
            
            if let _ = operation.id {
                callback()
                self.longPoll() { callback() }
            } else {
                print(Localisation.local("error.subscription.operation"))
            }
        }
    }
    
    //registering the device after creation
    func registerDevice(callback: @escaping (Bool) -> Void) {
        if let dev = Session.device {
            let params: Parameters = ["externalId": "\(Device.externalId)",  "type":"c8y_Serial"]
            netPost(to: "\(Links.BASE_URL)/identity/globalIds/\(dev.id)/externalIds", with: params, headers: Headers.post()) {
                (result: NetworkResponse<RegisteredDevice>) in
                
                Session.registeredDevice = result.value
                
                callback(result.error == nil || result.error == .noError)
            }
        }
    }
    
    //registering template for smartrest
    //parameters:
    //name: template name
    //x-id: unique header which identifies the template
    //nameOfValues: array of strings which is converted to json body by smartrest
    //callback: callback function executin when registration is done
    private func registerTemplate(name: String, xid: String, nameOfValues: [String], callback: @escaping () -> Void) {
        guard nameOfValues.count == 3 else {
            fatalError("name of values should be 3")
        }
        
        let template = "10,200,POST,/measurement/measurements,application/vnd.com.nsn.cumulocity.measurement+json,application/vnd.com.nsn.cumulocity.measurement+json,&&,NUMBER NUMBER NUMBER NOW NUMBER,\"{\"\"\(name)\"\":{\"\"\(nameOfValues[0])\"\":{\"\"value\"\":&&},\"\"\(nameOfValues[1])\"\":{\"\"value\"\":&&}, \"\"\(nameOfValues[2])\"\":{\"\"value\"\":&&}},\"\"time\"\":\"\"&&\"\",\"\"source\"\":{\"\"id\"\":\"\"&&\"\"},\"\"type\"\":\"\"c8y_Acceleration\"\"}\""
        
        
        var headers = Headers.authHeader()
        headers["X-Id"] = xid
        
        let op = NetworkOperation(type: .post, urlString: "\(Links.BASE_URL)/s", params: [:], textParameters: template, headers: headers) {
            (result: NetworkResponse<RawResponse>) in
            
            if let err = result.error, err != .noError {
                return
            }
            
            callback()
        }
        
        Session.operationQueue.addOperation(op)
    }
    
    //registering templates recursively
    func registerAllTemplates(templates: [CumulocitySensor] = CumulocitySensorController.shared.getSensors(), callback: @escaping () -> Void = { }) {
        var mutatedTemplates = templates
        
        for sensor in templates {
            
            self.registerTemplate(name: sensor.sensorType, xid: sensor.sensorTemplateXid, nameOfValues: sensor.nameOfValues) {
                mutatedTemplates.removeFirst()
                self.registerAllTemplates (templates: mutatedTemplates)
                
                if mutatedTemplates.count == 0  {
                    callback()
                    return
                }
            }
        }
    }
    
    //sending measurements to cumulocity
    //parameters
    //xid: unique id for identifying template where to send
    //measurements: values to send
    func sendMeasurement(xid: String, measurements: [String: Double]) {
        var headers = Headers.authHeader()
        headers["X-Id"] = xid
        
        let firstParameter = measurements["x"] ?? measurements["p"] ?? 0
        let secondParameter = measurements["y"] ?? measurements["a"] ?? 0
        let thirdParameter = measurements["z"] ?? measurements["r"] ?? 0
        
        let textParameter = "200,\(firstParameter),\(secondParameter),\(thirdParameter),\(Session.registeredDevice?.managedObject.id ?? "")"
        
        let op = NetworkOperation(type: .post,
                                    urlString: "\(Links.BASE_URL)/s",
                                    params: [:],
                                    textParameters: textParameter,
                                    headers: headers) { (result: NetworkResponse<RawResponse>) in }
        
        Session.operationQueue.addOperation(op)
    }
}

