//
//  RoundedViewExtension.swift
//  Salli
//
//  Created by Omar Khodr on 8/3/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit

extension UIView {
    func rounded(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
