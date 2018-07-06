//
//  Gyroscope.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 05/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

//protocol for notifying viewcontrollers that the sensor data has been fetched
protocol MotionDelegate {
    func gyroDataFetched(gyroValue: GyroscopeValue)
    func accDataFetched(accValue: AccelerometerValue)
    func rotationDataFetched(rotValue: RotationValue)
    func magneticFieldDataFetched(magValue: MagneticFieldValue)
}

open class Motion {
    static let shared: Motion = Motion()
    
    let accInterval = 0.5
    let gyroInterval = 0.5
    let motionInterval = 0.5
    let magnoInterval = 0.5
    
    private let motionManager = CMMotionManager()
    var motionDelegate: MotionDelegate?
    
    init() {
        //setting intervals for each sensor
        motionManager.accelerometerUpdateInterval = accInterval
        motionManager.gyroUpdateInterval = gyroInterval
        motionManager.deviceMotionUpdateInterval = motionInterval
        motionManager.magnetometerUpdateInterval = magnoInterval
    }
    
    //accelerometer monitoring
    func startAccelerometerMonitoring() {
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: OperationQueue()) {
                (data, error) in
                
                if let x = data?.acceleration.x, let y = data?.acceleration.y, let z = data?.acceleration.z {
                    if Settings.AccelerometerEnable {
                        self.motionDelegate?.accDataFetched(accValue: AccelerometerValue(x,y,z))
                    }
                }
            }
        } else {
            print("No accelerometer available")
        }
    }
    
    //gyroscope monitoring
    func startGyroscopeMonitoring() {
        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates(to: OperationQueue()) {
                (data, error) in
                if let x = data?.rotationRate.x, let y = data?.rotationRate.y, let z = data?.rotationRate.z {
                    if Settings.GyroEnabled {
                         self.motionDelegate?.gyroDataFetched(gyroValue: GyroscopeValue(x,y,z))
                    }
                }
            }
        } else {
            print("No gyroscope available for the device")
        }
    }
    
    //rotation monitoring
    func startRotationMonitoring() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: OperationQueue()) {
                (data, error) in
                if let pitch = data?.attitude.pitch, let rotMatrix = data?.attitude.rotationMatrix, let yaw = data?.attitude.yaw {
                    if Settings.RotationEnabled {
                        let az = Double.pi + atan2(rotMatrix.m22, rotMatrix.m12)
                        self.motionDelegate?.rotationDataFetched(rotValue: RotationValue(-1 * pitch.toDegrees,az.toDegrees, yaw.toDegrees))
                    }
                }
            }
        } else {
            print("No rotation available for the device")
        }
    }
    
    //magnetic field monitoring
    func startMagneticFieldMonitoring() {
        if motionManager.isMagnetometerAvailable {
            motionManager.startMagnetometerUpdates(to: OperationQueue()) {
                (data, error) in
                if let x = data?.magneticField.x, let y = data?.magneticField.y, let z = data?.magneticField.z {
                    if Settings.MagneticFieldEnabled {
                        self.motionDelegate?.magneticFieldDataFetched(magValue: MagneticFieldValue(x,y,z))
                    }
                }
            }
        } else {
            print("No magnometer available for the device")
        }
    }
}

