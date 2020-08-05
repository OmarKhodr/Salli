//
//  DefaultsManager.swift
//  Salli
//
//  Created by Omar Khodr on 8/3/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class DefaultsManager {
    let defaults = UserDefaults.standard
    let dict: [Int: UIUserInterfaceStyle] = [
        0: .unspecified,
        1: .light,
        2: .dark
    ]
    
    func changeTheme(val: Int, viewController: UIViewController) {
        viewController.view.window?.overrideUserInterfaceStyle = dict[val]!
    }
    
    func setupDefaults() -> Bool {
        defaults.set(false, forKey: K.Keys.needUpdatingSettings)
        let hasOnboarded = defaults.bool(forKey: K.Keys.hasOnboarded)
        if !hasOnboarded {
            defaults.set(true, forKey: K.Keys.hasOnboarded)
            defaults.set(false, forKey: K.Keys.automaticLocation)
            defaults.set("Cupertino", forKey: K.Keys.manualCity)
            defaults.set("United States", forKey: K.Keys.manualCountry)
            defaults.set(false, forKey: K.Keys.showMidnightTime)
            defaults.set(false, forKey: K.Keys.showImsakTime)
            defaults.set(0, forKey: K.Keys.appearance)
            defaults.set(3, forKey: K.Keys.calculationMethod)
            return false
        } else {
            return true
        }
    }
    
    func setupViews(viewController: UIViewController) {
        changeTheme(val: defaults.integer(forKey: K.Keys.appearance), viewController: viewController)
        viewController.performSegue(withIdentifier: K.Segues.toOnboarding, sender: viewController)
    }
}
