//
//  BaseMotionSensor.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 18/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let sensorDataFethed = Notification.Name("SensorDataFetched")
}

class CumuloitySensorImplementation : CumulocitySensor {
    typealias T = Double
    
    //MARK: derived properties from CumulocitySensor
    var sensorName: String
    var sensorType: String
    var nameOfValues: [String]
    var minimumTimeInterval: Double
    var sensorTemplateXid: String
    var sensorEnabled: Bool
    
    var lastUpdateMills: TimeInterval = 0.0
    
    init() {
        sensorName = ""
        sensorType = ""
        nameOfValues = []
        minimumTimeInterval = 0
        sensorTemplateXid = ""
        sensorEnabled = false
    }
    
    //MARK: derived methods from CumulocitySensor
    func register(sensorName: String, sensorType: String, nameOfValues: [String], minimumTimeInterval: Double) {
        self.sensorName = sensorName
        self.sensorType = sensorType
        self.nameOfValues = nameOfValues
        self.minimumTimeInterval = minimumTimeInterval
        self.sensorEnabled = false
        
        self.sensorTemplateXid = CumulocitySensorController.shared.getSensorTemplateId(sensorName: sensorName)
    }
    
    func setSensorStatus(enabled: Bool) {
        sensorEnabled = enabled
    }
    
    func sendData(values: [String: T]) {
        guard values.count == nameOfValues.count else {
            fatalError(Localisation.local("sensor.values.not.equal.names"))
        }
        
        let data: [String: Any] = [
            "x-id": sensorTemplateXid,
            "values": values
        ]
        
        
        if sensorEnabled && Date().timeIntervalSince1970 - minimumTimeInterval >= lastUpdateMills {
            NotificationCenter.default.post(name: .sensorDataFethed, object: nil, userInfo: ["data": data])
            lastUpdateMills = Date().timeIntervalSince1970
        }
    }
}
