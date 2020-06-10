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
    static func currentPrayer(_ times: [Date]) -> String {
        
        let currTime = Date().time

        //i from fajr (0) to maghrib (4) to not hightlight midnight or imsak
        for i in 0...times.count-1 {
            
            let previous = times[i].time
            let next = times[i+1].time
            
            if previous < next {
                let range = previous..<next
                
                //i != 1 for sunrise, don't want to highlight sunrise
                if range.contains(currTime) {
                    return K.prayersArray[i]
                }
            }
            else {
                let rangePre = previous..<Time(23,59)
                let rangePost = Time(0,0)..<next
                
                if rangePre.contains(currTime) || rangePost.contains(currTime) {
                    return K.prayersArray[i]
                }
            }
            
        }
        return ""
    }
    
    //uses current prayer to determine next one using an array with a counter that loops back to the beginning if needed (e.g. current is isha, then next is fajr).
    static func nextPrayer(_ times: [Date]) -> String {
        
        let current = currentPrayer(times)
        
        if current == "midnight" {
            return "fajr"
        }
        
        let prayers = K.prayersArray
        
        let nextPrayerIndex = (prayers.firstIndex(of: current)!+1) % prayers.count
        return prayers[nextPrayerIndex]
    }
    
    //calculates time between now and next prayer and returns tuple of hours and minutes left.
    static func timeUntilNextPrayer(_ times: [Date]) -> (Int, Int) {
        
        let next = nextPrayer(times)
        let prayers = K.prayersArray
        
        //get time value of next prayer
        let nextTime: Time = times[prayers.firstIndex(of: next)!].time
        //this is the float time value in order to calculate the difference correctly (e.g. 2h15min -> 2.25).
        let nextVal = Float(nextTime.hour) + Float(nextTime.minute)/60.0
        //likewise for current time
        let currTime = Date().time
        let currVal = Float(currTime.hour) + Float(currTime.minute)/60.0
        
        //in case val. of next prayer is less than curr. val (i.e. fajr most likely) the difference would be that between curr and midnight added to nextVal.
        let difference = nextVal >= currVal ? nextVal-currVal : 24-currVal+nextVal
        //converting difference from float format to hours/minutes to return.
        let hour = Int(difference)
        let minute = Int((difference-floor(difference))*60)
        return (hour, minute)
    }
    
    //formats final string for time left, takes dictionary to pass to timeUntilNextPrayer() and the capitalized version of the string for the next prayer
    static func timeLeftString(_ times: [Date], _ nextPrayer: String) -> String {
        let timeLeft: (Int, Int) = timeUntilNextPrayer(times)
        let hoursLeft = timeLeft.0
        let minutesLeft = timeLeft.1
        var timeLeftString = ""
        if (hoursLeft == 0 && minutesLeft == 1) {
            timeLeftString = "Less than a minute "
        }
        else {
            if (hoursLeft > 0) {
                timeLeftString += "\(hoursLeft) hour"
                if (hoursLeft > 1) {
                    timeLeftString += "s"
                }
                timeLeftString += " "
            }
            if (minutesLeft > 1) {
                timeLeftString += "\(minutesLeft) minutes"
                timeLeftString += " "
            }
            
        }
        timeLeftString += "until \(nextPrayer)"
        return timeLeftString
    }
}
