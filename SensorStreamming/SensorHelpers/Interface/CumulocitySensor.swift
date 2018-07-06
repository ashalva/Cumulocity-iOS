//
//  CumulocitySensor.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 18/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

//generic protocol for cumulosity sensor
protocol CumulocitySensor {
    typealias T = Double
    
    var sensorName: String { get set }
    var sensorType: String { get set }
    var nameOfValues: [String] { get set }
    var minimumTimeInterval: Double { get set }
    var sensorTemplateXid: String { get set }
    var sensorEnabled: Bool { get set }
    
    //send measurement for current sensor
    //parameter: values which should be sent to cumulocity platform
    func sendData(values: [String: T])
    
    //disable/enable the sensor
    func setSensorStatus(enabled: Bool)
    
    //register the sensor
    //parameters: sensor name: String
    //sensor type: String
    //name of values: array of strings - includes the keys which should be used for creating templates
    //minimum time interval: Double - minimum seconds to update the sensor values
    func register(sensorName: String, sensorType: String, nameOfValues: [String], minimumTimeInterval: Double) 
}
