//
//  OnboardingViewController.swift
//  Salli
//
//  Created by Omar Khodr on 8/3/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.rounded(cornerRadius: 8)
        // Do any additional setup after loading the view.
    }
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
