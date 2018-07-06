//
//  ViewController.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 27/09/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import UIKit
import AudioToolbox

let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

class HomeViewController: BaseViewController {
    let motion = Motion()
    
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var registeredStatusLabel: UILabel!
    @IBOutlet weak var createdStatusLabel: UILabel!
    @IBOutlet weak var accLabel: UILabel!
    @IBOutlet weak var gyroLabel: UILabel!
    @IBOutlet weak var magnometerLabel: UILabel!
    @IBOutlet weak var rotationLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    fileprivate var accSensor: AccelerometerSensor?
    fileprivate var gyroSensor: GyroscopeSensor?
    fileprivate var magneticSensor: MagneticSensor?
    fileprivate var rotationSensor: RotationSensor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home"
        
        loadingIndicator.startAnimating()
        
        //Requesting device credentials
        Session.shared.getCredentials () {
            CumulocitySensorController.shared.delegate = self
            CumulocitySensorController.shared.registerDevice()
            
            Motion.shared.motionDelegate = self
            
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
        }
    }
    
    
    private func startMeasuring() {
        
        accSensor = AccelerometerSensor()
        accSensor?.register(sensorName: "acceleration",
                            sensorType: "c8y_Acceleration",
                            nameOfValues: ["x","y","z"],
                            minimumTimeInterval: 0.5)
        
        gyroSensor = GyroscopeSensor()
        gyroSensor?.register(sensorName: "gyroscope",
                            sensorType: "c8y_Gyroscope",
                            nameOfValues: ["x","y","z"],
                            minimumTimeInterval: 0.5)
        
        magneticSensor = MagneticSensor()
        magneticSensor?.register(sensorName: "magneticfield",
                                 sensorType: "c8y_MagneticField",
                                 nameOfValues: ["x","y","z"],
                                 minimumTimeInterval: 0.5)
        
        rotationSensor = RotationSensor()
        rotationSensor?.register(sensorName: "rotation",
                                sensorType: "c8y_Rotation",
                                nameOfValues: ["p","a","r"],
                                minimumTimeInterval: 0.5)
        
        CumulocitySensorController.shared.addSensors(sensors: [accSensor!, gyroSensor!, magneticSensor!, rotationSensor!])
        
    }
}

//Delegate for interface controller, delegate methods are called from controller: CumulocitySensorController.swift class
extension HomeViewController: CumulocityControllerDelegate {
    
    func deviceRegistered() {
        //updating UI
        self.deviceIdLabel.text = "deviceId: \(Session.registeredDevice?.managedObject.id ?? "")"
        self.createdStatusLabel.text = Localisation.local("home.device.created")
        self.registeredStatusLabel.text = Localisation.local("home.device.registered")
        
        self.startMeasuring()
        
        //registering all templates for smartrest requests
        Session.shared.registerAllTemplates() {
            //after registration is finished and it is successful then start sending the data
            CumulocitySensorController.shared.startSending()
        }
    }
    
    //Operation received to vibrate
    func operationReceived() {
        showError(title: "Info", text: "Operation has been received")
        
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound (systemSoundID)
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func deviceRegistrationFailed() {
        showError(text: Localisation.local("home.registering.failed"))
    }
}

//Delegate which controls when the sensor data is retrieved, methods are called from Motion.swift class
extension HomeViewController : MotionDelegate {
    
    //rotation data retrieved
    func rotationDataFetched(rotValue: RotationValue) {
        DispatchQueue.main.async {
            self.rotationLabel.text = "rotation: p: \(rotValue.pitch.rounded(toPlaces: 2)), r: \(rotValue.roll.rounded(toPlaces: 2)), a: \(rotValue.azimuth.rounded(toPlaces: 2))"
        }
        
        rotationSensor?.sendData(values: ["p": rotValue.pitch, "a": rotValue.azimuth, "r": rotValue.roll ])
    }
    
    //magnetic field data retrieved
    func magneticFieldDataFetched(magValue: MagneticFieldValue) {
        DispatchQueue.main.async {
            self.magnometerLabel.text = "magnetic: x: \(magValue.x.rounded(toPlaces: 2)), y: \(magValue.y.rounded(toPlaces: 2)), z: \(magValue.z.rounded(toPlaces: 2))"
        }
        
        magneticSensor?.sendData(values: ["x": magValue.x, "y": magValue.y, "z": magValue.z])
    }
    
    //gyroscope data retrieved
    func gyroDataFetched(gyroValue: GyroscopeValue) {
        DispatchQueue.main.async {
            self.gyroLabel.text = "gyro: x: \(gyroValue.x.rounded(toPlaces: 2)), y: \(gyroValue.y.rounded(toPlaces: 2)), z: \(gyroValue.z.rounded(toPlaces: 2))"
        }
        
        gyroSensor?.sendData(values: ["x": gyroValue.x, "y": gyroValue.y, "z": gyroValue.z])
    }
    
    //accelerometer data retrieved
    func accDataFetched(accValue: AccelerometerValue) {
        DispatchQueue.main.async {
            self.accLabel.text = "acc: x: \(accValue.x.rounded(toPlaces: 2)), y: \(accValue.y.rounded(toPlaces: 2)), z: \(accValue.z.rounded(toPlaces: 2))"
        }
        
        accSensor?.sendData(values: ["x": accValue.x, "y": accValue.y,"z": accValue.z])
    }
}
