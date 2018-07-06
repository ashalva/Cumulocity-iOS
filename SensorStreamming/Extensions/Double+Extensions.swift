//
//  CGFloat+Extensions.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 08/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    //converting degrees to radians
    var toRadians: Double { return self * .pi / 180 }
    
    //converting radians to degrees
    var toDegrees: Double { return self * 180 / .pi }
}
