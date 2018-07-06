//
//  Subscribtion.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 23/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import SwiftyJSON

class Subscribtion: FromRawJSON {
    var channel: String?
    var subscription: String?
    var successfull: Bool?
    
    required convenience init?(raw: Any) {
        guard let json = raw as? JSON else {
            return nil
        }
        self.init(json: json)
    }
    
    init?(json: JSON) {
        if let j = json.arrayValue.first {
            channel = j["channel"].stringValue
            subscription = j["subscription"].stringValue
            successfull = j["successful"].boolValue
        }
    }
}
