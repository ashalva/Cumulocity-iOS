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
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            instanceUrlTextField.text = "https://iosapp.cumulocity.com"
            userNameTextField.text = "avanashvili5@gmail.com"
            passwordTextField.text = "iOSAppTesting"
        #endif
        
        navigationItem.title = "Login"
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        guard let instanceUrl = instanceUrlTextField.text,
                let userName = userNameTextField.text,
                let password = passwordTextField.text else {
            showError(text: Localisation.local("error.gneric"))
            
            return
        }
        
        if instanceUrl.isEmpty, userName.isEmpty, password.isEmpty  {
            showError(text: Localisation.local("login.fields.should.be.filled"))
            return
        }
        
        //assigning values to the settings
        Settings.InstanceUrl = instanceUrl
        Settings.UserName = userName
        Settings.Password = password
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") else {
            print("Unable to instantiate viewcontroller: MainTabBarController")
            return
        }
        
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
}

