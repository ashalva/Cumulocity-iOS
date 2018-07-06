//
//  String+Extensions.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 19/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import Alamofire

extension String: ParameterEncoding {
    //encoding string to base64
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}
