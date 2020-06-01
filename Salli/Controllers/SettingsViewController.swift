//
//  SettingsViewController.swift
//  Salli
//
//  Created by Omar Khodr on 5/30/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    let settings = ["Method", "Location", "About"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    @IBAction func doneBarButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource Methods
extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        
        cell.textLabel?.text = settings[indexPath.row]
        return cell
        
    }
    
}

//MARK: - UITableViewDelegate Methods
extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(settings[indexPath.row])
    }
}
