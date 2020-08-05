//
//  SwiftLocalizedExtension.swift
//  Salli
//
//  Created by Omar Khodr on 7/5/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation

//extension of String to avoid using NSLocalizedString's init every time we want to use a localized string.
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
