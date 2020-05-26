//
//  PrayerTimeManager.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import Foundation
import CoreLocation

class PrayerTimesManager {
    
    var delegate: PrayerTimesManagerDelegate?
    
    func fetchPrayerTimes(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(K.prayerTimesURL)&latitude=\(latitude)&longitude=\(longitude)&method=4"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                if let safeData = data {
                    if let model = self.parseJSON(safeData) {
                        self.delegate?.didUpdatePrayerTimes(self, model)
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ prayerTimesData: Foundation.Data) -> PrayerTimesModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PrayerTimesData.self, from: prayerTimesData)
            let model = PrayerTimesModel(fajr: decodedData.data.timings.Fajr,
                                         sunrise: decodedData.data.timings.Sunrise,
                                         dhuhr: decodedData.data.timings.Dhuhr,
                                         asr: decodedData.data.timings.Asr,
                                         maghrib: decodedData.data.timings.Maghrib,
                                         isha: decodedData.data.timings.Isha)
            return model
            
        }
        catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
}
