//
//  PrayerTimeManager.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation
import CoreLocation


//Handles requests and responses from the Prayer Times API to fetch the latest prayer times
//link: https://aladhan.com/prayer-times-api

class PrayerTimesManager {
    
    //takes delegate to do operations (on UI, for e.g.) when events occur, such as when prayer times are updated or when an error occurs
    var delegate: PrayerTimesManagerDelegate?
    
    //called from CLLocationManager's didUpdateLocation() method where the current location's latitude and longitude are taken to complete the URL to perform the GET request from the
    func fetchPrayerTimes(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        //completes URL with latitude and longitude and the 4th method of prayer times calculations, currently hardcoded as 4 - Umm Al-Qura University, Makkah
        let urlString = "\(K.prayerTimesURL)&latitude=\(latitude)&longitude=\(longitude)&method=4"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //1. Creating URL from string
        if let url = URL(string: urlString) {
            //2. Creating URLSession
            let session = URLSession(configuration: .default)
            //3. Adding task to the session with the newly created URL along with completion handler method to handle success or failure of GET request
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.delegate?.didFailWithError(self, error: error)
                    return
                }
                if let safeData = data {
                    //parse received JSON data and pass model to delegate
                    if let model = self.parseJSON(safeData) {
                        self.delegate?.didUpdatePrayerTimes(self, model)
                    }
                    
                }
            }
            //4. Starting the task (it says resume() but it actually just starts it)
            task.resume()
        }
    }
    
    func parseJSON(_ prayerTimesData: Foundation.Data) -> PrayerTimesModel? {
        //initializes decoder
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PrayerTimesData.self, from: prayerTimesData)
            //create model from decoded data of type PrayerTimesData to properly format the dates from strings to actual date types
            let model = PrayerTimesModel(fajr: decodedData.data.timings.Fajr,
                                         sunrise: decodedData.data.timings.Sunrise,
                                         dhuhr: decodedData.data.timings.Dhuhr,
                                         asr: decodedData.data.timings.Asr,
                                         maghrib: decodedData.data.timings.Maghrib,
                                         isha: decodedData.data.timings.Isha)
            //return the model for it to be passed as argument to didUpdatePrayerTimes() to be used by the delegate
            return model
            
        }
        catch {
            //in case decoding fails (usually either bad format of the JSON response or bad format of data class)
            delegate?.didFailWithError(self, error: error)
            return nil
        }
        
    }
    
    
}
