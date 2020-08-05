//
//  ManualLocationViewController.swift
//  Salli
//
//  Created by Omar Khodr on 8/5/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class ManualLocationViewController: UITableViewController {

    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 43.5
        cityTextField.text = defaults.string(forKey: K.Keys.manualCity)
        countryTextField.text = defaults.string(forKey: K.Keys.manualCountry)
        tableView.tableFooterView = UIView()
        cityTextField.delegate = self
        countryTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveLocation(cityTextField)
        saveLocation(countryTextField)
        defaults.set(true, forKey: K.Keys.needUpdatingSettings)
    }

}

extension ManualLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
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
