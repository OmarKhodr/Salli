//
//  QiblaViewController.swift
//  Salli
//
//  Created by Omar Khodr on 7/5/20.
//  Copyright © 2020 Omar Khodr. All rights reserved.
//

import UIKit
import CoreLocation
import Adhan

class QiblaViewController: UIViewController {

    @IBOutlet weak var compassImageView: UIImageView!
    @IBOutlet weak var qiblaArrow: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var warningStackView: UIStackView!
    private let loadingVC = LoadingViewController()
    
    private let defaults = UserDefaults.standard
    private let locationManager = CLLocationManager()
    //qibla direction in radians. Will be used by heading updating method to compute rotation of qibla arrow once coordinates are determined.
    private var qiblaRad: Double = 0
    private var facingQibla: Bool = false
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        //initially, before getting location to get qibla direction, arrow not visible
        qiblaArrow.layer.opacity = 0
        
        //programmatically add the indicator line for current direction.
        let lineView = UIView()
        lineView.backgroundColor = .label
        view.addSubview(lineView)

        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: lineView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let verticalConstraint = NSLayoutConstraint(item: lineView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: compassImageView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: compassImageView.frame.size.height/3.91)
        
        let widthConstraint = NSLayoutConstraint(item: lineView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 3)
        
        let heightConstraint = NSLayoutConstraint(item: lineView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        
        //constraints: centerX, width=3, height=50, aligned with compass image's "lines"
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        //set qibla arrow blending mode.
        qiblaArrow.layer.compositingFilter = "differenceBlendMode"
        lineView.layer.compositingFilter = "differenceBlendMode"
        
        let automaticLocation = defaults.bool(forKey: K.Keys.automaticLocation)
        if let lat = latitude, let lon = longitude, !automaticLocation {
            startQiblaDirection(latitude: lat, longitude: lon)
        } else {
            add(loadingVC)
            warningStackView.isHidden = true
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        
        //start real-time updating of heading (= degrees from true/magnetic north)
        if CLLocationManager.headingAvailable() {
            //update every change of 1 degree.
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func startQiblaDirection(latitude: Double, longitude: Double) {
        //once we can get qibla direction, make qibla arrow appear again
        UIView.animate(withDuration: 0.35) {
            self.qiblaArrow.layer.opacity = 100
        }
        //init. coordinates as Adhan library wants them.
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        //use Adhan library to get Qibla direction relative to true north
        let qiblaDirection = Qibla(coordinates: coordinates)
        qiblaRad = degreesToRadians(qiblaDirection.direction)
        //call didUpdateHeading() now in case it isn't changing (i.e device set on table or something)
        if let heading = locationManager.heading {
            self.locationManager(locationManager, didUpdateHeading: heading)
        }
    }
    
    //animated rotation to a defined rotation angle (radians).
    func rotate(view: UIView, to angle: Double) {
        UIView.animate(withDuration: 0.35) {
            view.transform = CGAffineTransform(rotationAngle: CGFloat(-angle))
        }
    }
    //animated rotation a certain value in radians.
    func rotate(view: UIView, radians: Double) {
        UIView.animate(withDuration: 0.35) {
            view.transform = view.transform.rotated(by: CGFloat(radians))
        }
    }

    //converts degrees to radians
    func degreesToRadians(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
}

extension QiblaViewController: CLLocationManagerDelegate {
    //method that gets triggered when location, managed by CLLocationManager, is updated
    //input is self and array of fetched locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get last location fetched
        if let location = locations.last {
            //stop updating location while fetching from array
            locationManager.stopUpdatingLocation()
            DispatchQueue.main.async {
                self.loadingVC.remove()
            }
            startQiblaDirection(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    //in case updating location fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to update location: \(error)")
    }
    
    //called every time heading changes: rotate compass and qibla arrow images to match new heading.
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let newRad = degreesToRadians(newHeading.trueHeading)
        let isVisible = qiblaArrow.layer.opacity == 100
        //only generate haptic feedback if withtin 1 degree of qibla, the qibla arrow is fully opaque and we've already left it or have never reached it
        if abs(newRad-qiblaRad) <= degreesToRadians(1) && isVisible && !facingQibla {
            facingQibla = true
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
        else {
            facingQibla = false
        }
        //rotate compass image to new true north and qibla arrow along with it
        rotate(view: compassImageView, to: newRad)
        rotate(view: qiblaArrow, to: newRad-qiblaRad)
    }
}
