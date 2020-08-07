//
//  PrayerTimesManagerDelegate.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation

protocol PrayerTimesManagerDelegate {
    func didUpdatePrayerTimes(_ manager: PrayerTimesManager, _ model: PrayerTimesModel)
    func didFailWithError(_ manager: PrayerTimesManager, error: Error)
    func didFailReverseGeolocation(_ manager: PrayerTimesManager, error: Error)
}
