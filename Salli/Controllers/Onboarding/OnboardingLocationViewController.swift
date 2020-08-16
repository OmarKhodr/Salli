//
//  OnboardingLocationViewController.swift
//  Salli
//
//  Created by Omar Khodr on 8/14/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class OnboardingLocationViewController: UIViewController {
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    var textFieldDelegate: LocationTextFieldDelegate!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.rounded(cornerRadius: 8)
        textFieldDelegate = LocationTextFieldDelegate()
        textFieldDelegate.cityTextField = self.cityTextField
        textFieldDelegate.countryTextField = self.countryTextField
        cityTextField.delegate = textFieldDelegate
        countryTextField.delegate = textFieldDelegate
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        if textFieldsAreValid() {
            defaults.set(cityTextField.text!, forKey: K.Keys.manualCity)
            defaults.set(countryTextField.text!, forKey: K.Keys.manualCountry)
            defaults.set(true, forKey: K.Keys.needUpdatingSettings)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldsAreValid() -> Bool {
        if let city = cityTextField.text, let country = countryTextField.text {
            return city != "" && country != ""
        } else {
            return false
        }
    }
}
