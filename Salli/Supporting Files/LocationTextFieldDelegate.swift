//
//  LocationTextFieldDelegate.swift
//  Salli
//
//  Created by Omar Khodr on 8/14/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class LocationTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    var cityTextField: UITextField?
    var countryTextField: UITextField?
    let defaults = UserDefaults.standard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cityTextField {
            countryTextField?.becomeFirstResponder()
        } else {
            countryTextField?.resignFirstResponder()
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Please type something"
            return false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("textFieldDidEndEditing called!")
    }
    
    func saveLocation(_ textField: UITextField) {
        if let text = textField.text {
            if textField == cityTextField {
                defaults.set(text, forKey: K.Keys.manualCity)
            } else {
                defaults.set(text, forKey: K.Keys.manualCountry)
            }
        }
    }
}
