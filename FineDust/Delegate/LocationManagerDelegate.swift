//
//  z.swift
//  FineDust
//
//  Created by 홍승아 on 2021/08/31.
//

import CoreLocation

protocol LocationManagerDelegate {
  func currentLocationUpdate(coordinate: CLLocationCoordinate2D)
  func currentLocationError()
}
