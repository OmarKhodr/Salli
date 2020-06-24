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
        
        //TESTING - hiding midnight and imsak HStacks for now.
        midnightHStack.isHidden = true
        imsakHStack.isHidden = true
        
        //clearing labels to prepare them for being updated by Core Data and/or CLLocationManager
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
        
        
        //fetching data (if available) from database and checking if still valid, request location to update them if either check fails.
        loadTimes()
        
        //timer for calling updateUI() on separate thread every tenth of a second.
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
            prayerTimesManager.fetchTimings(coordinates: location)
            
        }
    }
    
    //in case updating location fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to update location: \(error)")
    }
    
    func requestLocation() {
        // Request location permission in case app isn't allowed
        locationManager.requestWhenInUseAuthorization()
        //request location
        locationManager.requestLocation()
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

    }
}



extension TimesViewController {
    
//MARK: - Core Data Methods
    
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
    
    //assigns data inside PrayerInfo entry into prayerTimes array and location string
    func assignData(with info: PrayerInfo) {
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
    }
    
    //fetches the single instance of PrayerInfo and returns it (optional in case of error or non-existence of data
    func fetch(with request: NSFetchRequest<PrayerInfo> = PrayerInfo.fetchRequest()) -> PrayerInfo? {
        do {
            let array = try context.fetch(request)
            return array.first
        }
        catch {
            print("error fetching request: \(error)")
            return nil
        }
    }
    
    func loadTimes() {
        let info: PrayerInfo? = fetch()
        if let info = info {
            assignData(with: info)
        }
        updateTimes(with: info)
    }
    
    func updateTimes(with info: PrayerInfo?) {
        if let info = info {
            let dateFetched = info.dateFetched!
            
            //time between now and time data was last updated, in seconds
            let age = abs(Date().distance(to: dateFetched))
            
            //time at which we fetched data
            let timeFetched = dateFetched.time
            let currTime = Date().time
            
            //if time between now and date of creation is more than 24 hours or time of creation is bigger than current time (i.e. current time has passed midnight), delete entry from database and empty result array
            if (age > K.dayInSeconds || timeFetched > currTime) {
                requestLocation()
            }
        }
        else {
            requestLocation()
        }
    }
    
//MARK: - UI Helper Methods
    
    @objc func updateUI() {
        
        //if prayerTimes not yet loaded into array, nothing to update.
        if prayerTimes.count == 0 {
            return
        }
        
        //use model to get string of next prayer
        var nextPrayer = PrayerCurrentInformation.nextPrayer(prayerTimes)
        //capitalize first character
        nextPrayer = nextPrayer.prefix(1).capitalized + nextPrayer.dropFirst()
        //set string for time left using model function to which we pass captialized string of next prayer
        timeLeftString = PrayerCurrentInformation.timeLeftString(prayerTimes, nextPrayer)
        
        //use model to get string of current prayer
        let currentPrayer = PrayerCurrentInformation.currentPrayer(prayerTimes)
        
        //get "index" of current prayer using constant array of prayer names
        var currentTag = K.prayersArray.firstIndex(of: currentPrayer)!
        
        //if prayer tag is either 1 (Sunrise), 6 (Midnight) or 7 (Imsak), do not highlight
        let noHighlight = [1,6,7]
        if noHighlight.contains(currentTag) {
            currentTag = -1
        }
        
        let highlightColor = UIColor(named: K.Colors.brandBlue)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        //updating UI elements on main thread.
        DispatchQueue.main.async {
            
            self.locationLabel.text = self.locationString
            
            self.timeLeftLabel.text = self.timeLeftString
            
            //setting time labels using prayerTimes property
            for timeLabel in self.prayerTimeLabels {
                timeLabel.text = formatter.string(from: self.prayerTimes[timeLabel.tag])
            }
            
            //reset colors of all labels to initial color
            self.resetLabelColors(of: self.prayerLabels)
            self.resetLabelColors(of: self.prayerTimeLabels)
            
            //set highlight color to current prayer
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

