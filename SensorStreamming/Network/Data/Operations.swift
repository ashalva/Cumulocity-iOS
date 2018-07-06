//
//  Operations.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 23/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import SwiftyJSON

class Operations:FromRawJSON {
    var id: String?
    var deviceId: String?
    var channel: String?
    
    required convenience init?(raw: Any) {
        guard let json = raw as? JSON else {
            return nil
        }
        self.init(json: json)
    }
    
    init?(json: JSON) {
        if let j = json.arrayValue.first {
            let data = j["data"]["data"]
            
            id = data["id"].string
            deviceId = data["deviceId"].string
            channel = j["channel"].string
        }
    }
}
