//
//  NetworkOperation.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 27/09/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import Alamofire

class NetworkOperation<T: FromRemoteSource> : AsyncOperation {
    private let urlString: String
    private let completion: (NetworkResponse<T>) -> Void
    private let methodType: HTTPMethod
    private let parameters: [String: Any]
    private let headers: HTTPHeaders?
    private let textParameters: String?
    
    weak var request: Alamofire.Request?
    
    init(type: HTTPMethod = .get,
         urlString: String,
         params: [String: Any] = [:],
         textParameters: String? = nil,
         headers: HTTPHeaders? = nil,
         completion: @escaping (NetworkResponse<T>) -> Void) {
        self.urlString = urlString
        self.completion = completion
        self.methodType = type
        self.parameters = params
        self.textParameters = textParameters
        self.headers = headers
        super.init()
    }
    
    override func main() {
        request = Session.shared.restRequest(type: methodType, string: urlString, parameters: parameters, textParameters: textParameters, headers: headers) {
            (result: NetworkResponse<T>) in
            
            self.completion(result)
            self.completeOperation()
        }
        if request == nil {
            self.completeOperation()
        }
    }
    
    override func cancel() {
        request?.cancel()
        super.cancel()
    }
}
