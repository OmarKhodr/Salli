//
//  AlertService.swift
//  Salli
//
//  Created by Omar Khodr on 8/5/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

class AlertService {
    func alert(imageName: String, imageColor: UIColor, title: String, body: String, cancelVisible: Bool, actionName: String, completion: @escaping () -> Void) -> AlertViewController {
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(identifier: "AlertVC") as! AlertViewController
        alertVC.alertImageName = imageName
        alertVC.alertImageColor = imageColor
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.cancelVisible = cancelVisible
        alertVC.alertAction = actionName
        alertVC.alertCompletion = completion
        return alertVC
    }
    
    func warningAlert(title: String, body: String, cancelVisible: Bool, actionName: String, completion: @escaping () -> Void) -> AlertViewController {
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(identifier: "AlertVC") as! AlertViewController
        alertVC.alertImageName = "exclamationmark.triangle.fill"
        alertVC.alertImageColor = .systemYellow
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.cancelVisible = cancelVisible
        alertVC.alertAction = actionName
        alertVC.alertCompletion = completion
        return alertVC
    }
}
