//
//  CalculationSettingsViewController.swift
//  Salli
//
//  Created by Omar Khodr on 7/16/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class CalculationSettingsViewController: UITableViewController {
    
    var methods: [CalculationMethod] = [
    CalculationMethod(name: "Shia Ithna-Ansari"),
    CalculationMethod(name: "University of Islamic Sciences, Karachi"),
    CalculationMethod(name: "Islamic Society of North America"),
    CalculationMethod(name: "Muslim World League"),
    CalculationMethod(name: "Umm Al-Qura University, Makkah"),
    CalculationMethod(name: "Egyptian General Authority of Survey"),
    CalculationMethod(name: "Institute of Geophysics, University of Tehran"),
    CalculationMethod(name: "Gulf Region"),
    CalculationMethod(name: "Kuwait"),
    CalculationMethod(name: "Qatar"),
    CalculationMethod(name: "Majlis Ugama Islam Singapura, Singapore"),
    CalculationMethod(name: "Union Organization islamic de France"),
    CalculationMethod(name: "Diyanet İşleri Başkanlığı, Turkey"),
    CalculationMethod(name: "Spiritual Administration of Muslims of Russia")
    ]
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        let selectedMethod: Int = defaults.integer(forKey: K.Keys.calculationMethod)
        methods[selectedMethod].selected = true
        tableView.reloadData()
    }

}

//MARK: - TableViewDataSource Methods
extension CalculationSettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return methods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calcMethodCell", for: indexPath)
        cell.textLabel?.text = methods[indexPath.row].name
        cell.accessoryType = methods[indexPath.row].selected ? .checkmark : .none
        return cell
    }
}

//MARK: - TableViewDelegate Methods
extension CalculationSettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for method in methods {
            method.selected = false
        }
        methods[indexPath.row].selected = true
        defaults.set(indexPath.row, forKey: K.Keys.calculationMethod)
        defaults.set(true, forKey: K.Keys.needUpdatingSettings)
        tableView.reloadData()
    }
}
