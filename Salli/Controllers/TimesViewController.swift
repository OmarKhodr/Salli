//
//  TimesViewController.swift
//  Salli
//
//  Created by Omar Khodr on 5/26/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class TimesViewController: UIViewController {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var timeUntilLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var prayerTimesBackgroundView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
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
    
    //initialize location manager for requesting/fetching current location
    var locationManager = CLLocationManager()
    //initialize prayer times manager for sending and handling requests to the Prayer Times API
    var prayerTimesManager = PrayerTimesManager()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Setting date label as current Hijri date
        let dateFor = DateFormatter()

        let hijriCalendar = Calendar.init(identifier: Calendar.Identifier.islamicCivil)
        dateFor.locale = Locale.init(identifier: "en") // or "en" as you want to show numbers

        dateFor.calendar = hijriCalendar

        dateFor.dateFormat = "EEEE, MMM d, yyyy"
        currentDateLabel.text = "\(dateFor.string(from: Date())) AH"
        
        //adding rounded corners to background of prayer times
        prayerTimesBackgroundView.layer.cornerRadius = 12
        prayerTimesBackgroundView.layer.masksToBounds = true
        
        //adding rounded corners to refresh button
        refreshButton.layer.cornerRadius = 12
        refreshButton.layer.masksToBounds = true
        
        //adding rounded corners to settings button
        settingsButton.layer.cornerRadius = 12
        settingsButton.layer.masksToBounds = true
        
        // setting view as delegate for location manager
        locationManager.delegate = self
        
        //setting view as delegate for prayer times manager
        prayerTimesManager.delegate = self
        
        //load prayer times either through valid data in database or fetching updated times if they're outdated, after which it updateUI() is called either by fetchPrayerTimes() in case data is outdated or the function itself in case it isn't.
        loadTimes()
        
        //timer for calling loadTimes() every second.
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimesViewController.loadTimes), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        animate(button: sender)
        //refresh button calls loadTimes() so doesn't send HTTP request unless stored times are invalid
        loadTimes()
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        animate(button: sender)
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
        
        //first delete everything currently in PrayerInfo table (by design there should only be a single entry) to save a new one.
        let request: NSFetchRequest<PrayerInfo> = PrayerInfo.fetchRequest()
        do {
            let array = try context.fetch(request)
            for entry in array {
                context.delete(entry)
            }
            saveContext()
        }
        catch {
            print("error deleting old entries in database: \(error)")
        }

        //dictionary from model which contains just-fetched times
        let dict = model.times
        
        //creating table entry for updated prayer times and saving them
        let newPrayerInfo = PrayerInfo(context: context)
        newPrayerInfo.dateFetched = Date()
        newPrayerInfo.fajr = dict[K.fajr]!
        newPrayerInfo.sunrise = dict[K.sunrise]!
        newPrayerInfo.dhuhr = dict[K.dhuhr]!
        newPrayerInfo.asr = dict[K.asr]!
        newPrayerInfo.maghrib = dict[K.maghrib]!
        newPrayerInfo.isha = dict[K.isha]!
        
        //save entry in table
        saveContext()
        
        updateUI(with: dict)

    }
}

//MARK: - Supporting Methods

extension TimesViewController {
    
    //saving Core Data context.
    func saveContext () {
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
    
    //function for loading prayer times to display on UI.
    //two possible scenarios:
    //1- database either has no previously stored prayer info or has outdated data (previous day's prayer times for e.g.) in which case a request to get the current location is sent.
    //2- database already has updated prayer times in which case they're read from the database.
    @objc func loadTimes() {
        //initialize fetch request to read prayer times from database to determine if they exist and if they are valid.
        let request: NSFetchRequest<PrayerInfo> = PrayerInfo.fetchRequest()
        do {
            var array = try context.fetch(request)
            //if more than one entry in database, impossible since by design only one entry is stored at a time so throw an exception.
            if (array.count > 1) {
                throw ImpossibleDatabaseStateError.runtimeError(array.count)
            }
            else {
                //if entry exists, check if valid and remove it from database
                if (array.count == 1) {
                    let info = array.first!
                    let age = abs(Date().distance(to: (info.dateFetched)!))
                    //if time between now and date of creation is more than 24 hours, delete entry from database and empty result array
                    if (age > K.dayInSeconds) {
                        context.delete(info)
                        saveContext()
                        array = []
                    }
                }
                //check again if entry is still in result array in which case it's valid
                if (array.count == 1) {
                    let info = array.first!
                    //store found data in dictionary which matches model's way of storing times so that we can pass it to updateUI().
                    let times: [String: Date] = [
                        K.fajr: info.fajr!,
                        K.sunrise: info.sunrise!,
                        K.dhuhr: info.dhuhr!,
                        K.asr: info.asr!,
                        K.maghrib: info.maghrib!,
                        K.isha: info.isha!
                    ]
                    updateUI(with: times)
                }
                //if database never had an entry or entry was removed because it was invalid, request location to updated prayer times.
                else {
                    // Request location permission in case app isn't allowed
                    locationManager.requestWhenInUseAuthorization()
                    //request location
                    locationManager.requestLocation()
                }
            }
        }
        catch {
            print("error fetching request: \(error)")
        }
    }
    
    func updateUI(with dict: [String: Date]) {
        
        //fetching dates from the model and coverting them to strings in --:-- AM/PM format.
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        //dictionary to fetch which labels we want to target (in this case, color current prayer blue) based on their string names.
        let labels: [String: (UILabel, UILabel)] = [
            K.fajr : (fajrLabel, fajrTimeLabel),
            K.dhuhr : (dhuhrLabel, dhuhrTimeLabel),
            K.asr : (asrLabel, asrTimeLabel),
            K.maghrib : (maghribLabel, maghribTimeLabel),
            K.isha : (ishaLabel, ishaTimeLabel)
        ]
        
        //get string of current prayer.
        let current: String = Model.currentPrayer(dict)

        //set labels that we will color blue to reference those of current prayer time.
        let currLabel: UILabel? = labels[current]?.0
        let currTimeLabel: UILabel? = labels[current]?.1
        
        //get string of next prayer then capitalize first letter to display on UI.
        var nextPrayer: String = Model.nextPrayer(dict)
        nextPrayer = nextPrayer.prefix(1).capitalized + nextPrayer.dropFirst()
        
        //get time left string, fully formattted thanks to Model.
        let timeLeftString = Model.timeLeftString(dict, nextPrayer)

        //calling main thread asynchronously to update UI elements
        DispatchQueue.main.async {
            //set prayer time labels.
            self.fajrTimeLabel.text = formatter.string(from: dict[K.fajr]!)
            self.sunriseTimeLabel.text = formatter.string(from: dict[K.sunrise]!)
            self.dhuhrTimeLabel.text = formatter.string(from: dict[K.dhuhr]!)
            self.asrTimeLabel.text = formatter.string(from: dict[K.asr]!)
            self.maghribTimeLabel.text = formatter.string(from: dict[K.maghrib]!)
            self.ishaTimeLabel.text = formatter.string(from: dict[K.isha]!)
            //if current labels were assigned non-nil values then we should color the labels they reference (can be nil if no time has to be colored, e.g. sunrise).
            if let currLabel = currLabel, let currTimeLabel = currTimeLabel {
                currLabel.textColor = #colorLiteral(red: 0.1450980392, green: 0.5137254902, blue: 0.8549019608, alpha: 1)
                currTimeLabel.textColor = #colorLiteral(red: 0.1450980392, green: 0.5137254902, blue: 0.8549019608, alpha: 1)
            }
            //set string of time left label
            self.timeUntilLabel.text = timeLeftString
        }
    }
    
    func animate(button: UIButton) {
        //animate button by shrinking to 95% size for a tenth of a second then back to original size in the same time
        UIView.animate(withDuration: 0.1,
        animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        },
        completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = CGAffineTransform.identity
            }
        })
    }
}

