//
//  PrayerTimesModel.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation
import CoreLocation

//model for prayer times after having fetched them from API request
struct PrayerTimesModel {
    
    //dictionary containing datetimes for prayers
    var times: [Date]
    var location: String
    var latitude: Double
    var longitude: Double
    
    //constructor takes strings of times in 24-hour format (as it comes from API request) and converts them to date types
    init(stringArray arr: [String], location: String, latitude: Double, longitude: Double) {
        times = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        for i in 0..<arr.count {
            var date = dateFormatter.date(from: arr[i])!
            if i == 6 || i == 7 {
                date += K.dayInSeconds
            }
            times.append(date)
        }
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from info: PrayerInfo) {
        self.times = [
            info.fajr!,
            info.sunrise!,
            info.dhuhr!,
            info.asr!,
            info.maghrib!,
            info.isha!,
            info.midnight!,
            info.imsak!
        ]
        self.location = info.location!
        self.latitude = info.latitude
        self.longitude = info.longitude
    }
}
