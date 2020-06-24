//
//  PrayerTimesModel.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation

//model for prayer times after having fetched them from API request
struct PrayerTimesModel {
    
    //dictionary containing datetimes for prayers
    var times: [Date]
    var location: String
    
    //constructor takes strings of times in 24-hour format (as it comes from API request) and converts them to date types
    init(stringArray arr: [String], location: String) {
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
    }
    
    init(times: [Date], location: String) {
        self.times = times
        self.location = location
    }
}
