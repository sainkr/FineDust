//
//  CurrentLocationViewModel.swift
//  FineDust
//
//  Created by 홍승아 on 2021/05/31.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class CurrentLocationViewModel{
  
  lazy var observable = PublishRelay<String>()
  
  private let fineDustListViewModel = FineDustListViewModel()
  
  func convertToAddress(latitude: Double, longtitude: Double, mode: FineDustVCMode){
    _ = loadLocation(latitude: latitude, longtitude: longtitude)
      .take(1)
      .subscribe(onNext:{ [weak self] response in
        self?.observable.accept(response.locationName)
        if mode == .currentLocation {
          self?.fineDustListViewModel.setCurrentLocationLocationData(response)
        }else if mode == .searched {
          self?.fineDustListViewModel.setSearchedLocationData(response)
        }
      })
  }
  
  func convertToAddress(latitude: Double, longtitude: Double, completion: @escaping (String) -> ()){
    _ = loadLocation(latitude: latitude, longtitude: longtitude)
      .take(1)
      .subscribe(onNext:{ response in
        completion(response.locationName)
      })
  }
  
  private func loadLocation(latitude: Double, longtitude: Double) -> Observable<LocationData>{
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
