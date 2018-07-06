//
//  CumulocityControllerDelegate.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 20/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

//protocol for sending all necessary information to subscribed viewcontrollers
protocol CumulocityControllerDelegate {
    func deviceRegistered()
    func deviceRegistrationFailed()
    func operationReceived()
}
