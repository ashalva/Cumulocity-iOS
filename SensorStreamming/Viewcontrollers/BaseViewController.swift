//
//  BaseViewController.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 20/11/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    func showError(title:String = "Error", text : String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
