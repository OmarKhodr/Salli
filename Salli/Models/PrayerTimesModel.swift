//
//  PrayerTimesModel.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation

class PrayerTimesModel {
    
    var times: [String: Date]
    init(fajr: String, sunrise: String, dhuhr: String, asr: String, maghrib: String, isha: String) {
        times = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        times[K.fajr] = dateFormatter.date(from: fajr)
        times[K.sunrise] = dateFormatter.date(from: sunrise)
        times[K.dhuhr] = dateFormatter.date(from: dhuhr)
        times[K.asr] = dateFormatter.date(from: asr)
        times[K.maghrib] = dateFormatter.date(from: maghrib)
        times[K.isha] = dateFormatter.date(from: isha)
    }
}
