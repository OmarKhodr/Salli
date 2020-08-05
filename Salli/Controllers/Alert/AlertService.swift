//
//  AlertService.swift
//  Salli
//
//  Created by Omar Khodr on 8/5/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class AlertService {
    func alert(imageName: String, title: String, body: String, actionName: String, completion: @escaping () -> Void) -> AlertViewController {
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(identifier: "AlertVC") as! AlertViewController
        alertVC.alertImageName = imageName
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.alertAction = actionName
        alertVC.alertCompletion = completion
        return alertVC
    }
}
