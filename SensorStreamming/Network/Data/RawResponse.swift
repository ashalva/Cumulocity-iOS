//
//  File.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 01/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import SwiftyJSON

class RawResponse : FromRawJSON {
    let json: JSON
    required init?(raw: Any) {
        guard let json = raw as? JSON else {
            return nil
        }
        
        self.json = json
    }
}
