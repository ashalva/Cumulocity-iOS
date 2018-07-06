//
//  CumulocitySensorController.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 20/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

class CumulocitySensorController {
    //singlton object, which is shared in whole app
    static let shared = CumulocitySensorController()
    
    private var allSensors: [CumulocitySensor] = []
    var delegate: CumulocityControllerDelegate?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendData), name: .sensorDataFethed, object: nil)
    }
    
    //whole device registration logic which includes creating + registering + initialising operations
    func registerDevice() {
        Session.isDeviceRegistered() {
            (registered: Bool) in
            if registered {
                self.delegate?.deviceRegistered()
                self.initOperations()
            } else {
                Session.shared.createDevice(externalId: Device.externalId) {
                    (success: Bool) in
                    if !success {
                        self.delegate?.deviceRegistrationFailed()
                        return
                    }
                    
                    Session.shared.registerDevice() {
                        (success: Bool) in
                        if success {
                            self.delegate?.deviceRegistered()
                            self.initOperations()
                        } else {
                            self.delegate?.deviceRegistrationFailed()
                        }
                    }
                }
            }
        }
    }
    
    //operation initialising logic
    private func initOperations() {
        Session.shared.handShake() {
            Session.shared.subscribe() {
                Session.shared.longPoll {
                    self.delegate?.operationReceived()
                }
            }
        }
    }
    
    func getSensors() -> [CumulocitySensor] {
        return allSensors
    }
    
    //creating template name for smart rest
    //parameter: sensor name : String
    func getSensorTemplateId(sensorName: String) -> String {
        return "madp_ios_\(sensorName.lowercased())_1.1"
    }
    
    //send measurement method, using smartrest
    //parameter: notification which includes all necessary information to send data to cumulocity
    @objc func sendData(_ notification: NSNotification) {
        if let data = (notification.userInfo?["data"] as? [String: Any]) {
            if let xid = data["x-id"] as? String, let values = data["values"] as? [String: Double] {
                Session.shared.sendMeasurement(xid: xid , measurements: values)
            }
        }
    }
    
    //adding sensors to array controlled by controller.
    //parameter: array of CumulocitySensor
    func addSensors(sensors: [CumulocitySensor]) {
        for sensor in sensors {
            let allIndex = allSensors.index { $0.sensorName == sensor.sensorName && $0.sensorType == sensor.sensorType }
            if let _ = allIndex {
                fatalError("\(Localisation.local("sensor.already.exists")), name: \(sensor.sensorName). Skipping...")
            }
            
            allSensors.append(sensor)
        }
    }
    
    //removing sensors to array controlled by controller.
    //parameter: array of CumulocitySensor
    func removeSensors(sensors: [CumulocitySensor]) {
        for sensor in sensors {
            let allIndex = allSensors.index { $0.sensorName == sensor.sensorName && $0.sensorType == sensor.sensorType }
            if let indx = allIndex {
                allSensors.remove(at: indx)
            } else {
                print("\(Localisation.local("sensor.doesnot.exist")), name: \(sensor.sensorName). Skipping...")
            }
        }
    }
    //adding sensor to array controlled by controller
    //parameter: single CumulocitySensor
    func addSensor(sensor: CumulocitySensor) {
        let allIndex = allSensors.index { $0.sensorName == sensor.sensorName && $0.sensorType == sensor.sensorType }
        if let _ = allIndex {
            fatalError(Localisation.local("sensor.already.exists"))
        }
        
        allSensors.append(sensor)
    }
    
    //removing sensor to array controlled by controller
    //parameter: single CumulocitySensor
    func removeSensor(sensor: CumulocitySensor) {
        let allIndex = allSensors.index { $0.sensorName == sensor.sensorName && $0.sensorType == sensor.sensorType }
        if let indx = allIndex {
            allSensors.remove(at: indx)
        }
    }
    
    //enabling all sensor status to start sending the data.
    func startSending() {
        for sensor in allSensors {
            sensor.setSensorStatus(enabled: true)
        }
    }
}
