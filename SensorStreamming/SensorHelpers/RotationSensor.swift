//
//  RotationSensor.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 18/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

class RotationSensor : CumuloitySensorImplementation {
    override func register(sensorName: String, sensorType: String, nameOfValues: [String], minimumTimeInterval: Double) {
        super.register(sensorName: sensorName, sensorType: sensorType, nameOfValues: nameOfValues, minimumTimeInterval: minimumTimeInterval)
        
        Motion.shared.startRotationMonitoring()
    }
}
