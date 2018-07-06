//
//  Accelerometer.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 06/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

class AccelerometerValue {
    var x: Double
    var y: Double
    var z: Double
    
    init (_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}
