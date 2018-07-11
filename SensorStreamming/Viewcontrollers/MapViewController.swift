//
//  MapViewController.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 11/07/2018.
//  Copyright © 2018 Shalva Avanashvili. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Map"
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Settings.LocationEnabled = status == .authorizedWhenInUse
        
        if status != .authorizedWhenInUse { return }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let userLocation: CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(userLocation.latitude) \(userLocation.longitude)")
        
        setUserLocation(manager.location!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        setUserLocation(userLocation) 
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(text: Localisation.local("map.location.failed"))
    }
    
    func setUserLocation(_ location: CLLocation) {
        let userCoordinate = location.coordinate
        let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: userCoordinate, eyeAltitude: 400.0)

        mapView.setCamera(mapCamera, animated: true)
    }
}
