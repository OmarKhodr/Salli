//
//  Constants.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation

class K {
    
    static let prayerTimesURL = "https://api.aladhan.com/v1/"
    static let prayersArray = ["fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha", "midnight", "imsak"]
    static let fajr = "fajr"
    static let sunrise = "sunrise"
    static let dhuhr = "dhuhr"
    static let asr = "asr"
    static let maghrib = "maghrib"
    static let isha = "isha"
    static let dayInSeconds: Double = 24*3600
    
    struct Colors {
        static let brandBlue = "brandBlue"
    }
    
    struct Keys {
        static let hasOnboarded = "hasOnboarded"
        static let automaticLocation = "automaticLocation"
        static let manualCity = "manualCity"
        static let manualCountry = "manualCountry"
        static let showMidnightTime = "showMidnightTime"
        static let showImsakTime = "showImsakTime"
        static let calculationMethod = "calculationMethod"
        static let appearance = "appearance"
        static let needUpdatingSettings = "needUpdatingSettings"
    }
    
    struct Segues {
        static let toOnboarding = "ToOnboarding"
        static let toQibla = "ToQibla"
        static let toSettings = "ToSettings"
        static let toManualLocation = "ToManualLocation"
    }
}
