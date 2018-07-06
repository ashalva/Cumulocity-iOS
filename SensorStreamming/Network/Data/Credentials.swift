//
//  Credentials.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 20/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import SwiftyJSON

class Credentials : FromRawJSON {
    
    var id : String
    var password: String
    var url: String
    var tenantId: String
    var username: String
    
    
    required convenience init?(raw: Any) {
        guard let json = raw as? JSON else {
            return nil
        }
        self.init(json: json)
    }
    
    init?(json: JSON) {
        id = json["id"].stringValue
        password = json["password"].stringValue
        tenantId = json["tenandId"].stringValue
        url = json["self"].stringValue
        username = json["username"].stringValue
    }
}
