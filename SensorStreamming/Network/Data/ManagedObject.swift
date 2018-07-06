//
//  ManagedObject.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 01/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import SwiftyJSON

class ManagedObject {
    let id : String
    let self_: String
    
    init(json: JSON) {
        id = json["id"].stringValue
        self_ = json["self"].stringValue
    }
}
