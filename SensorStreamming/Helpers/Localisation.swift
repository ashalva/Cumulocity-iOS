//
//  Localisation.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 04/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

class Localisation {
    //method which retrieves the strings from resoure file
    //Resources/Localisation.strings
    static func local(_ string: String) -> String {
        return NSLocalizedString(string, comment: "")
    }
}
