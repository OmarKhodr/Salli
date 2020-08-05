//
//  SettingsViewController.swift
//  Salli
//
//  Created by Omar Khodr on 5/30/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation
import UIKit

class RootSettingsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
        
    }
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate Methods
extension RootSettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
    }
}
