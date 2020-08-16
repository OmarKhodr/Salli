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
    var textFieldDelegate: LocationTextFieldDelegate!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 43.5
        cityTextField.text = defaults.string(forKey: K.Keys.manualCity)
        countryTextField.text = defaults.string(forKey: K.Keys.manualCountry)
        tableView.tableFooterView = UIView()
        
        textFieldDelegate = LocationTextFieldDelegate()
        textFieldDelegate.cityTextField = cityTextField
        textFieldDelegate.countryTextField = countryTextField
        cityTextField.delegate = textFieldDelegate
        countryTextField.delegate = textFieldDelegate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveLocation(cityTextField)
        saveLocation(countryTextField)
        defaults.set(true, forKey: K.Keys.needUpdatingSettings)
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
