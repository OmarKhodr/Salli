//
//  AboutSettingsViewController.swift
//  Salli
//
//  Created by Omar Khodr on 7/16/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit
import MessageUI

class AboutSettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton!
    
    var version: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let versionNum = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            version = versionNum
            self.versionLabel.text = "Version \(version)"
        }
        
//        contactButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        contactButton.rounded(cornerRadius: 8)
    }
    
    @IBAction func iconsLinkTapped(_ sender: UIButton) {
        if let url = URL(string: "https://icons8.com") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func contactButtonPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["omar.khoder2000@gmail.com"])
            mail.setSubject("Salli v\(version) Feedback")

            present(mail, animated: true)
        } else {
            print("Couldn't open mail composer!")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
