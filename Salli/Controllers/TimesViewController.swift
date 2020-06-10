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
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var prayerTimesBackgroundView: UIView!
    
    @IBOutlet var prayerLabels: [UILabel]!
    @IBOutlet var prayerTimeLabels: [UILabel]!
    
    @IBOutlet weak var midnightHStack: UIStackView!
    @IBOutlet weak var imsakHStack: UIStackView!
    
    var prayerTimes: [Date] = []
    
    var locationString: String = ""
    
    var timeLeftString: String = ""
    
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //initialize location manager for requesting/fetching current location
    var locationManager = CLLocationManager()
    //initialize prayer times manager for sending and handling requests to the Prayer Times API
    var prayerTimesManager = PrayerTimesManager()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        midnightHStack.isHidden = true
        imsakHStack.isHidden = true
        
        locationLabel.text = ""
        timeLeftLabel.text = ""
        currentDateLabel.text = ""
        
        //Setting date label as current Hijri date
        let dateFor = DateFormatter()

        let hijriCalendar = Calendar.init(identifier: Calendar.Identifier.islamicCivil)
        dateFor.locale = Locale.init(identifier: "en") // or "en" as you want to show numbers

        dateFor.calendar = hijriCalendar

        dateFor.dateFormat = "EEEE, MMM d, yyyy"
        currentDateLabel.text = "\(dateFor.string(from: Date())) AH"
        
        //adding rounded corners to background of prayer times
        prayerTimesBackgroundView.layer.cornerRadius = 16
        prayerTimesBackgroundView.layer.masksToBounds = true
        
        //setting view as delegate for location manager
        locationManager.delegate = self
        
        //setting view as delegate for prayer times manager
        prayerTimesManager.delegate = self
        
        //load prayer times either through valid data in database or fetching updated times if they're outdated, after which it updateUI() is called either by fetchPrayerTimes() in case data is outdated or the function itself in case it isn't.
        loadTimes()
        
        //timer for calling loadTimes() every tenth of a second.
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TimesViewController.updateUI), userInfo: nil, repeats: true)
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
            //call method of prayer times manager to perform GET request from the API to fetch the latest prayer times and update the UI
            prayerTimesManager.fetchPrayerTimes(withLocation: location)
            
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
        let times = model.times
        let location = model.location
        
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
        newPrayerInfo.location = location
        
        //save entry in table
        saveContext()
        
        prayerTimes = times
        locationString = location
        
        updateUI()

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
                    prayerTimes = [
                        info.fajr!,
                        info.sunrise!,
                        info.dhuhr!,
                        info.asr!,
                        info.maghrib!,
                        info.isha!,
                        info.midnight!,
                        info.imsak!
                    ]
                    locationString = info.location!
                    
                    updateUI()

                    
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
    
    @objc func updateUI() {
        
        if prayerTimes.count == 0 {
            return
        }
        
        var nextPrayer = Model.nextPrayer(prayerTimes)
        nextPrayer = nextPrayer.prefix(1).capitalized + nextPrayer.dropFirst()
        timeLeftString = Model.timeLeftString(prayerTimes, nextPrayer)
        
        let currentPrayer = Model.currentPrayer(prayerTimes)
        
        var currentTag = K.prayersArray.firstIndex(of: currentPrayer)!
        
        let noHighlight = [1,6,7]
        if noHighlight.contains(currentTag) {
            currentTag = -1
        }
        
        let highlightColor = UIColor(named: K.Colors.brandBlue)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        DispatchQueue.main.async {
            
            self.locationLabel.text = self.locationString
            
            self.timeLeftLabel.text = self.timeLeftString
            
            for timeLabel in self.prayerTimeLabels {
                let string = formatter.string(from: self.prayerTimes[timeLabel.tag])
                timeLabel.text = string
            }
            
            self.resetLabelColors(of: self.prayerLabels)
            self.resetLabelColors(of: self.prayerTimeLabels)
            
            self.setLabelColor(in: self.prayerLabels, tag: currentTag, color: highlightColor)
            self.setLabelColor(in: self.prayerTimeLabels, tag: currentTag, color: highlightColor)
        }
        
    }
    
    func resetLabelColors(of labelArray: [UILabel]) {
        for label in labelArray {
            label.textColor = .label
        }
    }
    
    func setLabelColor(in labelArray: [UILabel], tag: Int, color: UIColor?) {
        for label in labelArray {
            if label.tag == tag  {
                label.textColor = color
            }
        }
    }
    
    //was using to animate buttons which don't exist anymore, might use later
//    func animate(button: UIButton) {
//        //animate button by shrinking to 95% size for a tenth of a second then back to original size in the same time
//        UIView.animate(withDuration: 0.1,
//        animations: {
//            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        },
//        completion: { _ in
//            UIView.animate(withDuration: 0.1) {
//                button.transform = CGAffineTransform.identity
//            }
//        })
//    }
    
}

