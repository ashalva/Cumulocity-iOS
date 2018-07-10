//
//  Links.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 27/09/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation


class Links {
    static let BASE_URL = "https://iosapp.cumulocity.com"
    
    var restURL: URL!
    
    init() {
        restURL = URL(string: Links.BASE_URL)
    }
}
