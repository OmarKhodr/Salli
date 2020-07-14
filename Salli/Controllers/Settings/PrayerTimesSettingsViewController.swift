//
//  PrayerTimesSettingsViewController.swift
//  Salli
//
//  Created by Omar Khodr on 7/14/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class PrayerTimesSettingsViewController: UITableViewController {
    
    @IBOutlet weak var showMidnightSwitch: UISwitch!
    @IBOutlet weak var showImsakSwitch: UISwitch!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showMidnightSwitch.isOn = defaults.bool(forKey: K.Keys.showMidnightTime)
        showImsakSwitch.isOn = defaults.bool(forKey: K.Keys.showImsakTime)
    }
    
    @IBAction func showMidnightToggled(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: K.Keys.showMidnightTime)
    }
    @IBAction func showImsakToggled(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: K.Keys.showImsakTime)
    }
    
    
    

}
