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
import Adhan

class TimesViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var prayerTimesBackgroundView: UIView!
    
    @IBOutlet var prayerLabels: [UILabel]!
    @IBOutlet var prayerTimeLabels: [UILabel]!
    @IBOutlet var periodLabels: [UILabel]!
    
    
    @IBOutlet weak var midnightHStack: UIStackView!
    @IBOutlet weak var imsakHStack: UIStackView!
    
    var prayerTimes: [Date] = []
    
    var locationString: String = ""
    
    var timeLeftString: String = ""
    
    let coreDataHelper = CoreDataHelper()
    
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
        
        //fetching data (if available) from database and checking if still valid, request location to update them if either check fails.
        loadTimes()
        
        //timer for calling updateUI() on separate thread every tenth of a second.
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TimesViewController.updateUI), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func qiblaButtonPressed(_ sender: UIButton) {
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
           view.backgroundColor = .clear

           let blurEffect = UIBlurEffect(style: .dark)
           let blurEffectView = UIVisualEffectView(effect: blurEffect)
           //always fill the view
           blurEffectView.frame = self.view.bounds
           blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

           view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
           view.backgroundColor = .black
        }
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
        
        coreDataHelper.saveNewTimes(model: model)
        
        prayerTimes = model.times
        locationString = model.location

    }
}



extension TimesViewController {
    
//MARK: - Core Data Methods
    
    func loadTimes() {
        
        let result: [PrayerInfo] = coreDataHelper.fetch()
        
        guard result.count <= 1 else {
            fatalError("result has more than one element!!!")
        }
        
        let info = result.first
        
        if let info = info {
            (prayerTimes, locationString) = coreDataHelper.assignData(with: info)
        }
        
        if !coreDataHelper.upToDate(info: info) {
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
        
        var timeStrings: [[String]] = []
        for time in prayerTimes {
            timeStrings.append(formatter.string(from: time).components(separatedBy: " "))
        }
        
        //updating UI elements on main thread.
        DispatchQueue.main.async {
            
            self.locationLabel.text = self.locationString
            
            self.timeLeftLabel.text = self.timeLeftString
            
            //setting time labels using prayerTimes property
//            for timeLabel in self.prayerTimeLabels {
//                timeLabel.text = formatter.string(from: self.prayerTimes[timeLabel.tag])
//            }
            for timeLabel in self.prayerTimeLabels {
                timeLabel.text = timeStrings[timeLabel.tag][0]
            }
            for periodLabel in self.periodLabels {
                periodLabel.text = timeStrings[periodLabel.tag][1]
            }
            
            //reset colors of all labels to initial color
            self.resetLabelColors(of: self.prayerLabels)
            self.resetLabelColors(of: self.prayerTimeLabels)
            self.resetLabelColors(of: self.periodLabels)
            
            //set highlight color to current prayer
            self.setLabelColor(in: self.prayerLabels, tag: currentTag, color: highlightColor)
            self.setLabelColor(in: self.prayerTimeLabels, tag: currentTag, color: highlightColor)
            self.setLabelColor(in: self.periodLabels, tag: currentTag, color: highlightColor)
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

