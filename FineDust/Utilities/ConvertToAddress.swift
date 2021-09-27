//
//  ConverToAddres.swift
//  FineDust
//
//  Created by 홍승아 on 2021/09/01.
//

import CoreLocation
import Foundation

import RxSwift

class ConvertToAddress {
  static func loadLocationName(latitude: Double, longtitude: Double) -> Observable<LocationData>{
    return Observable.create{ emitter in
      let geoCoder = CLGeocoder()
      let locale = Locale(identifier: "Ko-kr")
      geoCoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longtitude), preferredLocale: locale, completionHandler: {(placemarks, error) in
        if let address: [CLPlacemark] = placemarks {
          guard let local_name = address.last?.name else {
            emitter.onNext(LocationData(locationName: "측정 불가", latitude: latitude, longtitude: longtitude))
            emitter.onCompleted()
            return
          }
          guard let local_city = address.last?.locality else {
            emitter.onNext(LocationData(locationName: "\(local_name)", latitude: latitude, longtitude: longtitude))
            emitter.onCompleted()
            return
          }
          guard let local_sub = address.last?.subLocality else {
            emitter.onNext(LocationData(locationName: "\(local_city)", latitude: latitude, longtitude: longtitude))
            emitter.onCompleted()
            return
          }
          emitter.onNext(LocationData(locationName: "\(local_city) \(local_sub)", latitude: latitude, longtitude: longtitude))
          emitter.onCompleted()
        }
      })
      return Disposables.create()
    }
  }
}
