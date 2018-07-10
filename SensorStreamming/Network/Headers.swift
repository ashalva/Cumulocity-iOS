//
//  Headers.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 01/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import Alamofire

class Headers {
    private static func baseHeaders() -> HTTPHeaders {
        return [ "Content-Type":"application/json",
                 "Accept":"application/json"
        ]
    }
    static func get() -> HTTPHeaders {
        return [
            "Authorization" : "Basic \(basicAuthHeaderVal() ?? "")"
        ]
    }
    
    static func post() -> HTTPHeaders {
        var headers = baseHeaders()
        headers["Authorization"] = "Basic \(basicAuthHeaderVal() ?? "")"
        return headers
    }
    
    static func credentialsPost() -> HTTPHeaders {
        var headers = baseHeaders()
        headers["Authorization"] = "Basic \(credentialsAuthHeaderVal() ?? "")"
        return headers
    }
    
    static func credentialsHeaders() -> HTTPHeaders {
        return ["Authorization" : "Basic bWFuYWdlbWVudC9kZXZpY2Vib290c3RyYXA6RmhkdDFiYjFm",
                "Content-Type" : "application/json"]
    }
    
    static func authHeader() -> HTTPHeaders {
        return [
            "Authorization" : "Basic \(basicAuthHeaderVal() ?? "")"
        ]
    }
    
    private static func credentialsAuthHeaderVal() -> String? {
        let val = "\(Session.credentials?.username ?? ""):\(Session.credentials?.password ?? "")"
        if let data = val.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    private static func basicAuthHeaderVal() -> String? {
        let val = "\(Settings.UserName):\(Settings.Password)"
        if let data = val.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
}
