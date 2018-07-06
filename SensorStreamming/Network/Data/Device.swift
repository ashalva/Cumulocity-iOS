//
//  Registration.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 01/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import SwiftyJSON

enum DeviceType : String {
    case c8y_Serial
    case unknown
}

class Device : FromRawJSON {
    let id: String
    let name: String
    let owner: String
    let type: DeviceType
    
    required convenience init?(raw: Any) {
        guard let json = raw as? JSON else {
            return nil
        }
        self.init(json: json)
    }
    
    init?(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        owner = json["owner"].stringValue
        if let tp = DeviceType(rawValue: json["type"].stringValue) {
            type = tp
        } else {
            type = .unknown
        }
    }
    
    public static let externalId = "phone-\(getSerialNumber())"

    public static func getSerialNumber() -> String {
        return UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: "")
    }
    
    public static func getModel() -> String {
        return UIDevice.current.model
    }
    
    public static func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    class ChildClass {
        
    }
}
