//
//  Rotation.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 30/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

class RotationValue {
    var pitch: Double
    var azimuth: Double
    var roll: Double
    
    
    init (_ pitch: Double, _ azimuth: Double, _ roll: Double) {
        self.pitch = pitch
        self.azimuth = azimuth
        self.roll = roll
    }
}
