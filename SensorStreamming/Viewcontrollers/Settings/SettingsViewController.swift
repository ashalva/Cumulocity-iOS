//
//  SettingsViewController.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 29/10/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : UITableViewController {
    
    @IBOutlet weak var rotationSwitch: UISwitch!
    @IBOutlet weak var magnometerSwitch: UISwitch!
    @IBOutlet weak var accSwitch: UISwitch!
    @IBOutlet weak var gyroSwitch: UISwitch!
    @IBOutlet weak var instanceUrlLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        
        accSwitch.addTarget(self, action: #selector(accSwitchChanged), for: UIControlEvents.valueChanged)
        gyroSwitch.addTarget(self, action: #selector(gyroSwitchChanged), for: UIControlEvents.valueChanged)
        magnometerSwitch.addTarget(self, action: #selector(magneticSwitchChanged), for: UIControlEvents.valueChanged)
        rotationSwitch.addTarget(self, action: #selector(rotationSwitchChanged), for: UIControlEvents.valueChanged)
        
        instanceUrlLabel.text = "Instance URL: \(Settings.InstanceUrl)"
        
        locationSwitch.isOn = Settings.LocationEnabled
    }
    
    @IBAction func locationSwitchChanged(_ sender: Any) {
        Settings.LocationEnabled = locationSwitch.isOn
    }
    
    @objc
    func accSwitchChanged() {
        Settings.AccelerometerEnable = accSwitch.isOn
    }
    
    @objc
    func gyroSwitchChanged() {
        Settings.GyroEnabled = gyroSwitch.isOn
    }
    
    @objc
    func magneticSwitchChanged() {
        Settings.MagneticFieldEnabled = magnometerSwitch.isOn
    }
    
    @objc
    func rotationSwitchChanged() {
        Settings.RotationEnabled = rotationSwitch.isOn
    }
}
