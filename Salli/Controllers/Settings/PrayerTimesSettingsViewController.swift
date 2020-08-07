//
//  PrayerTimesSettingsViewController.swift
//  Salli
//
//  Created by Omar Khodr on 7/14/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class PrayerTimesSettingsViewController: UITableViewController {
    
    @IBOutlet weak var automaticLocationSwitch: UISwitch!
    @IBOutlet weak var showMidnightSwitch: UISwitch!
    @IBOutlet weak var showImsakSwitch: UISwitch!
    @IBOutlet weak var manualLocationCell: UITableViewCell!
    @IBOutlet weak var locationLabel: UILabel!
    
    let defaults = UserDefaults.standard
    let alertService = AlertService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showMidnightSwitch.isOn = defaults.bool(forKey: K.Keys.showMidnightTime)
        showImsakSwitch.isOn = defaults.bool(forKey: K.Keys.showImsakTime)
        configureLocation(isAutomatic: defaults.bool(forKey: K.Keys.automaticLocation))
    }
    
    @IBAction func automaticLocationToggled(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: K.Keys.automaticLocation)
        defaults.set(true, forKey: K.Keys.needUpdatingSettings)
        configureLocation(isAutomatic: sender.isOn)
        defaults.set(true, forKey: K.Keys.needUpdatingSettings)
    }
    
    @IBAction func showMidnightToggled(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: K.Keys.showMidnightTime)
        defaults.set(true, forKey: K.Keys.needUpdatingSettings)
    }
    @IBAction func showImsakToggled(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: K.Keys.showImsakTime)
        defaults.set(true, forKey: K.Keys.needUpdatingSettings)
    }
    
    func configureLocation(isAutomatic: Bool) {
        if isAutomatic {
            manualLocationCell.selectionStyle = .none
            manualLocationCell.isUserInteractionEnabled = false
            manualLocationCell.accessoryType = .none
            automaticLocationSwitch.isOn = true
            locationLabel.text = "Automatic"
        } else {
            manualLocationCell.selectionStyle = .default
            manualLocationCell.isUserInteractionEnabled = true
            manualLocationCell.accessoryType = .disclosureIndicator
            automaticLocationSwitch.isOn = false
            if let city = defaults.string(forKey: K.Keys.manualCity),
                let _ = defaults.string(forKey: K.Keys.manualCountry) {
                locationLabel.text = city
            } else {
                let alertVC = alertService.warningAlert(title: "Invalid Location", body: "Either the city or country fields are empty. Please Enter a valid city and country.", cancelVisible: true, actionName: "Set Location") {
                    self.performSegue(withIdentifier: K.Segues.toManualLocation, sender: self)
                }
                present(alertVC, animated: true)
            }
            
        }
    }

}
