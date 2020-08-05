//
//  AppearanceSettingsViewController.swift
//  Salli
//
//  Created by Omar Khodr on 7/14/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class AppearanceSettingsViewController: UITableViewController {

    @IBOutlet weak var matchSystemCell: UITableViewCell!
    @IBOutlet weak var lightCell: UITableViewCell!
    @IBOutlet weak var darkCell: UITableViewCell!
    
    let defaults = UserDefaults.standard
    
    let dict: [Int: UIUserInterfaceStyle] = [
        0: .unspecified,
        1: .light,
        2: .dark
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        switch defaults.integer(forKey: K.Keys.appearance) {
        case 0:
            matchSystemCell.accessoryType = .checkmark
        case 1:
            lightCell.accessoryType = .checkmark
        case 2:
            darkCell.accessoryType = .checkmark
        default:
            break
        }
    }
    
    func reset() {
        matchSystemCell.accessoryType = .none
        lightCell.accessoryType = .none
        darkCell.accessoryType = .none
    }
    
    func changeTheme(val: Int) {
        self.view.window?.overrideUserInterfaceStyle = dict[val]!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reset()
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        defaults.set(indexPath.row, forKey: K.Keys.appearance)
        changeTheme(val: indexPath.row)
    }
    
}
