//
//  PrayerTimesCalculations.swift
//  Salli
//
//  Created by Omar Khodr on 6/1/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation

class Model {
    //takes dictionary from model containing the times to determine which prayer is the current one.
    static func currentPrayer(_ dict: [String: Date]) -> String {
        let currTime = Date().time
        switch currTime {
            case dict[K.fajr]!.time..<dict[K.sunrise]!.time:
                return K.fajr
        case dict[K.sunrise]!.time..<dict[K.dhuhr]!.time:
                return K.sunrise
            case dict[K.dhuhr]!.time..<dict[K.asr]!.time:
                return K.dhuhr
            case dict[K.asr]!.time..<dict[K.maghrib]!.time:
                return K.asr
            case dict[K.maghrib]!.time..<dict[K.isha]!.time:
                return K.maghrib
            case dict[K.isha]!.time..<Time(23, 59):
                return K.isha
            default:
                return ""
        }
    }
    
    //uses current prayer to determine next one using an array with a counter that loops back to the beginning if needed (e.g. current is isha, then next is fajr).
    static func nextPrayer(_ dict: [String: Date]) -> String {
        let current = currentPrayer(dict)
        let prayers = ["fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha"]
        let nextPrayerIndex = (prayers.firstIndex(of: current)!+1) % prayers.count
        return prayers[nextPrayerIndex]
    }
    
    //calculates time between now and next prayer and returns tuple of hours and minutes left.
    static func timeUntilNextPrayer(_ dict: [String: Date]) -> (Int, Int) {
        let next = nextPrayer(dict)
        //get time value of next prayer
        let nextTime: Time = dict[next]!.time
        //this is the float time value in order to calculate the difference correctly (e.g. 2h15min -> 2.25).
        let nextVal = Float(nextTime.hour) + Float(nextTime.minute)/60.0
        //likewise for current time
        let currTime = Date().time
        let currVal = Float(currTime.hour) + Float(currTime.minute)/60.0
        let difference = abs(nextVal-currVal)
        //converting difference from float format to hours/minutes to return.
        let hour = Int(difference)
        let minute = Int((difference-floor(difference))*60)
        return (hour, minute)
    }
    
    //formats final string for time left, takes dictionary to pass to timeUntilNextPrayer() and the capitalized version of the string for the next prayer
    static func timeLeftString(_ dict: [String: Date], _ nextPrayer: String) -> String {
        let timeLeft: (Int, Int) = timeUntilNextPrayer(dict)
        let hoursLeft = timeLeft.0
        let minutesLeft = timeLeft.1
        var timeLeftString = ""
        if (hoursLeft == 0 && minutesLeft == 0) {
            timeLeftString = "less than a minute "
        }
        else {
            if (hoursLeft > 0) {
                timeLeftString += "\(hoursLeft) hours "
            }
            if (minutesLeft > 0) {
                timeLeftString += "\(minutesLeft) minutes "
            }
            
        }
        timeLeftString += "until \(nextPrayer)"
        return timeLeftString
    }
}
