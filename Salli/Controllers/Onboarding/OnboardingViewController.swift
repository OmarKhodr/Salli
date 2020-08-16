//
//  OnboardingViewController.swift
//  Salli
//
//  Created by Omar Khodr on 8/3/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var featuresStackView: UIStackView!
    @IBOutlet weak var automaticLocationButton: UIButton!
    @IBOutlet weak var manualLocationButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        automaticLocationButton.rounded(cornerRadius: 8)
        manualLocationButton.rounded(cornerRadius: 8)
        // Do any additional setup after loading the view.
    }
    @IBAction func didTapAutomaticLocationButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        defaults.set(true, forKey: K.Keys.automaticLocation)
        defaults.set(true, forKey: K.Keys.needUpdatingSettings)
    }
}
