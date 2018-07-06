//
//  LoginViewController.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 04/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : BaseViewController {
    @IBOutlet weak var instanceUrlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            instanceUrlTextField.text = "https://iot.cs.ut.ee"
        #endif
        
        navigationItem.title = "Login"
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        let url = URL(string: "minuntelia://")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        return
        
        guard  let instanceUrl = instanceUrlTextField.text else {
            showError(text: Localisation.local("error.gneric"))
            return
        }
        
        if instanceUrl.isEmpty  {
            showError(text: Localisation.local("login.fields.should.be.filled"))
            return
        }
        
        //assigning values to our settings
        Settings.InstanceUrl = instanceUrl
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") else {
            print("Unable to instantiate viewcontroller: MainTabBarController")
            return
        }
        
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
}

