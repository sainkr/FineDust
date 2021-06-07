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
    
    lazy var observable = PublishRelay<CurrentLocation>()

    lazy var locationName = observable.map{
        "\($0.location_city) \($0.location_sub)"
    }

    func convertToAddressWith(coordinate: CLLocation){
        _ = laodLocation(coordinate: coordinate)
            .take(1)
            .bind(to: observable)
    }
    
    func laodLocation(coordinate: CLLocation) -> Observable<CurrentLocation>{
        return Observable.create{ emitter in
            let geoCoder = CLGeocoder()
            let locale = Locale(identifier: "Ko-kr")
            
            geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale, completionHandler: {(placemarks, error) in
                if let address: [CLPlacemark] = placemarks {
                    guard let local_region = address.last?.administrativeArea
                    , let local_city = address.last?.locality,
                          let local_sub = address.last?.subLocality else {
                        emitter.onError(NSError(domain: "data error", code: 0, userInfo: nil))
                        return
                    }
                    let location = CurrentLocation(location_city: local_city, location_sub: local_sub)
                    emitter.onNext(location)
                    emitter.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
}
