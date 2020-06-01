//
//  ImpossibleDatabaseStateError.swift
//  Salli
//
//  Created by Omar Khodr on 5/30/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation

enum ImpossibleDatabaseStateError: Error {
    case runtimeError(Int)
}
