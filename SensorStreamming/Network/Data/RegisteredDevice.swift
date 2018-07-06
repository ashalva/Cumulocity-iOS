//
//  RegisteredDevice.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 01/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import SwiftyJSON

class RegisteredDevice: FromRawJSON {
    let externalId : String
    let managedObject : ManagedObject
    let self_ : String
    let type: DeviceType
    
    required convenience init?(raw: Any) {
        guard let json = raw as? JSON else {
            return nil
        }
        self.init(json: json)
    }

    init?(json: JSON) {
        externalId = json["externalId"].stringValue
        managedObject = ManagedObject(json: json["managedObject"])
        self_ = json["self"].stringValue
        if let tp = DeviceType(rawValue: json["type"].stringValue) {
            type = tp
        } else {
            type = DeviceType.unknown
        }
    }
}
