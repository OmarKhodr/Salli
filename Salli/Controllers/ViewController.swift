//
//  ViewController.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, PrayerTimesManagerDelegate {
    

    @IBOutlet weak var fajrTimeLabel: UILabel!
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var dhuhrTimeLabel: UILabel!
    @IBOutlet weak var asrTimeLabel: UILabel!
    @IBOutlet weak var maghribTimeLabel: UILabel!
    @IBOutlet weak var ishaTimeLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var prayerTimesManager = PrayerTimesManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        
        prayerTimesManager.delegate = self
        
        // Request location permission in case app isn't allowed
        locationManager.requestWhenInUseAuthorization()
        
        //request location
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            prayerTimesManager.fetchPrayerTimes(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to update location: \(error)")
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdatePrayerTimes(_ manager: PrayerTimesManager, _ model: PrayerTimesModel) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let dict = model.times
        DispatchQueue.main.async {
            self.fajrTimeLabel.text = formatter.string(from: dict[K.fajr]!)
            self.sunriseTimeLabel.text = formatter.string(from: dict[K.sunrise]!)
            self.dhuhrTimeLabel.text = formatter.string(from: dict[K.dhuhr]!)
            self.asrTimeLabel.text = formatter.string(from: dict[K.asr]!)
            self.maghribTimeLabel.text = formatter.string(from: dict[K.maghrib]!)
            self.ishaTimeLabel.text = formatter.string(from: dict[K.isha]!)
        }
    }

}

