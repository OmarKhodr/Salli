//
//  PrayerTimesData.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation

struct PrayerTimesData: Codable {
    let data: Data
}

struct Data: Codable {
    let timings: Timings
}

struct Timings: Codable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
    let Midnight: String
    let Imsak: String
}
