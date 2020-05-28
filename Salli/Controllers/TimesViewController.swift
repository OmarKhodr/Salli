//
//  ViewController.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit
import CoreLocation

class TimesViewController: UIViewController {
    

    @IBOutlet weak var fajrTimeLabel: UILabel!
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var dhuhrTimeLabel: UILabel!
    @IBOutlet weak var asrTimeLabel: UILabel!
    @IBOutlet weak var maghribTimeLabel: UILabel!
    @IBOutlet weak var ishaTimeLabel: UILabel!
    
    @IBOutlet weak var fajrLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var dhuhrLabel: UILabel!
    @IBOutlet weak var asrLabel: UILabel!
    @IBOutlet weak var maghribLabel: UILabel!
    @IBOutlet weak var ishaLabel: UILabel!
    
    @IBOutlet weak var prayerTimesBackgroundView: UIView!
    
    var locationManager = CLLocationManager()
    var prayerTimesManager = PrayerTimesManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prayerTimesBackgroundView.layer.cornerRadius = 12;
        prayerTimesBackgroundView.layer.masksToBounds = true;
        
        // setting view as delegate for location manager
        locationManager.delegate = self
        
        //setting view as delegate for prayer times manager
        prayerTimesManager.delegate = self
        
        // Request location permission in case app isn't allowed
        locationManager.requestWhenInUseAuthorization()
        
        //request location
        locationManager.requestLocation()
    }

}

//MARK: - CLLocationManagerDelegate Methods
extension TimesViewController: CLLocationManagerDelegate {
    //method that gets triggered when location, managed by CLLocationManager, is updated
    //input is self and array of fetched locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get last location fetched
        if let location = locations.last {
            //stop updating location while fetching from array
            locationManager.stopUpdatingLocation()
            //get latitude and longitude
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            //call method of prayer times manager to perform GET request from the API to fetch the latest prayer times and update the UI
            prayerTimesManager.fetchPrayerTimes(latitude: lat, longitude: lon)
        }
    }
    
    //in case updating location fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to update location: \(error)")
    }
}

//MARK: - PrayerTimesManagerDelegate Methods
extension TimesViewController: PrayerTimesManagerDelegate {
    //called when updating prayer times fails
    func didFailWithError(_ manager: PrayerTimesManager, error: Error) {
        print(error)
    }
    
    //called to update UI when prayer times are updated
    func didUpdatePrayerTimes(_ manager: PrayerTimesManager, _ model: PrayerTimesModel) {
        //fetching dates from the model and coverting them to strings in --:-- AM/PM format
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        //dictionary of dates in model containing datetimes for prayers
        let dict = model.times
        //calling main thread asynchronously to update UI elements
        DispatchQueue.main.async {
            self.fajrTimeLabel.text = formatter.string(from: dict[K.fajr]!)
            self.sunriseTimeLabel.text = formatter.string(from: dict[K.sunrise]!)
            self.dhuhrTimeLabel.text = formatter.string(from: dict[K.dhuhr]!)
            self.asrTimeLabel.text = formatter.string(from: dict[K.asr]!)
            self.maghribTimeLabel.text = formatter.string(from: dict[K.maghrib]!)
            self.ishaTimeLabel.text = formatter.string(from: dict[K.isha]!)
            let currTime = Date().time
            var currLabel: UILabel?
            switch currTime {
            case dict[K.fajr]!.time..<dict[K.sunrise]!.time:
                currLabel = self.fajrLabel
                break
            case dict[K.dhuhr]!.time..<dict[K.asr]!.time:
                currLabel = self.dhuhrLabel
                break
            case dict[K.asr]!.time..<dict[K.maghrib]!.time:
                currLabel = self.asrLabel
                break
            case dict[K.maghrib]!.time..<dict[K.isha]!.time:
                currLabel = self.maghribLabel
                break
            case dict[K.isha]!.time..<Time(23, 59):
                currLabel = self.ishaLabel
                break
            default:
                break
            }
            if let currLabel = currLabel {
                currLabel.textColor = #colorLiteral(red: 0.1450980392, green: 0.5137254902, blue: 0.8549019608, alpha: 1)
            }
        }
    }
}

