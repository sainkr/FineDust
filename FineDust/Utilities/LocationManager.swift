//
//  LocationManger.swift
//  FineDust
//
//  Created by 홍승아 on 2021/08/31.
//

import CoreLocation
import UIKit

class LocationManager: NSObject {
  lazy var locationManager = CLLocationManager()
  var locationMangerDelegate: LocationManagerDelegate?
  
  func requestLocation() {
    locationManager.delegate = self
    guard CLLocationManager.locationServicesEnabled() else {
      return
    }
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  func requestLocation(completion: @escaping (_ coordinate: CLLocationCoordinate2D) -> ()) throws {
    locationManager.delegate = self
    guard CLLocationManager.locationServicesEnabled() else {
      throw LocationManagerError.locationServicesError
    }
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    guard let coordinate = locationManager.location?.coordinate else {
      throw LocationManagerError.coordinateError
    }
    completion(coordinate)
  }
}

// MARK: - Location Handling
extension LocationManager : CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways{
      guard let coordinate = locationManager.location?.coordinate else { return }
      locationMangerDelegate?.currentLocationUpdate(coordinate: coordinate)
    }
    if manager.authorizationStatus == .denied {
      locationMangerDelegate?.currentLocationError()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if manager.authorizationStatus == .denied {
      print("Failed to get users location.")
      locationMangerDelegate?.currentLocationError()
    }
  }
}
