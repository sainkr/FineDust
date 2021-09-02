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
          guard let local_city = address.last?.locality,
                let local_sub = address.last?.subLocality else {
            emitter.onError(NSError(domain: "data error", code: 0, userInfo: nil))
            return
          }
          
          let location = LocationData(locationName: "\(local_city) \(local_sub)", latitude: latitude, longtitude: longtitude)
          emitter.onNext(location)
          emitter.onCompleted()
        }
      })
      return Disposables.create()
    }
  }
}
