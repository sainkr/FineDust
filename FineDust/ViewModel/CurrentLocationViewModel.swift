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
    _ = ConvertToAddress.loadLocationName(latitude: latitude, longtitude: longtitude)
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
    _ = ConvertToAddress.loadLocationName(latitude: latitude, longtitude: longtitude)
      .take(1)
      .subscribe(onNext:{ response in
        completion(response.locationName)
      })
  }
}
