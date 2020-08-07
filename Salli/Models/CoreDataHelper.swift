//
//  CoreDataHelper.swift
//  Salli
//
//  Created by Omar Khodr on 6/25/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit
import CoreData

struct CoreDataHelper {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //saving Core Data context.
    private func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //fetches the single instance of PrayerInfo and returns it (optional in case of error or non-existence of data
    func fetch(with request: NSFetchRequest<PrayerInfo> = PrayerInfo.fetchRequest()) -> [PrayerInfo] {
        do {
            let array = try context.fetch(request)
            return array
        }
        catch {
            fatalError("error fetching request: \(error)")
        }
    }
    
    func upToDate(info: PrayerInfo?) -> Bool {
        if let info = info {
            
            let dateFetched = info.dateFetched!
            
            //time between now and time data was last updated, in seconds
            let age = abs(Date().distance(to: dateFetched))
            
            //time at which we fetched data
            let timeFetched = dateFetched.time
            let currTime = Date().time
            
            //if time between now and date of creation is more than 24 hours or time of creation is bigger than current time (i.e. current time has passed midnight), delete entry from database and empty result array
            if (age > K.dayInSeconds || timeFetched > currTime) {
                return false
            }
        }
        else {
            return false
        }
        return true
    }
    
    func saveNewTimes(model: PrayerTimesModel) {
        //first delete everything currently in PrayerInfo table (by design there should only be a single entry) to save a new one.
        let result: [PrayerInfo] = fetch()
        guard result.count <= 1 else {
            fatalError("More than one element in database!!!")
        }
        for entry in result {
            context.delete(entry)
        }
        //dictionary from model which contains just-fetched times
        let times = model.times
        //creating table entry for updated prayer times and saving them
        let newPrayerInfo = PrayerInfo(context: context)
        newPrayerInfo.dateFetched = Date()
        newPrayerInfo.fajr = times[0]
        newPrayerInfo.sunrise = times[1]
        newPrayerInfo.dhuhr = times[2]
        newPrayerInfo.asr = times[3]
        newPrayerInfo.maghrib = times[4]
        newPrayerInfo.isha = times[5]
        newPrayerInfo.midnight = times[6]
        newPrayerInfo.imsak = times[7]
        newPrayerInfo.location = model.location
        newPrayerInfo.latitude = model.latitude
        newPrayerInfo.longitude = model.longitude
        //save entry in table
        saveContext()
    }
}
