//
//  AlertViewController.swift
//  Salli
//
//  Created by Omar Khodr on 8/5/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    var alertImageName = ""
    var alertImageColor: UIColor?
    var alertTitle = ""
    var alertBody = ""
    var cancelVisible: Bool?
    var alertAction = ""
    var alertCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupData()
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        //CAUTION: DROP SHADOWS ARE EXPENSIVE, HAD TO REMOVE "CACHING" BECAUSE ALERT CAN EXPAND
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.2
        backgroundView.layer.shadowOffset = .zero
        backgroundView.layer.shadowRadius = 5
//        backgroundView.layer.shadowPath = UIBezierPath(rect: backgroundView.bounds).cgPath
        backgroundView.rounded(cornerRadius: 8)
    }
    func setupData() {
        alertImage.image = UIImage(systemName: alertImageName)
        alertImage.tintColor = alertImageColor!
        titleLabel.text = alertTitle
        bodyLabel.text = alertBody
        cancelButton.isHidden = !(cancelVisible!)
        actionButton.setTitle(alertAction, for: .normal)
    }
    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapAction(_ sender: UIButton) {
        alertCompletion?()
        dismiss(animated: true, completion: nil)
    }
    
}
