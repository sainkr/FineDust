//
//  ViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/05/25.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation


// 37.375125349085906, 127.95590235319048
// <tmX>284688.286381</tmX>
// <tmY>431240.919844</tmY>

// http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList?tmX=284667.69390013756&tmY=431073.56098829664&returnType=xml&serviceKey=ic1bRMghX2rxMK8sUa%2B2cyNOyPqz96fTfOIbi1fHykBtmAg4D2B46M2fsdC8z7B%2ByeS0xeIsXdmiKqIrUFdevA%3D%3D

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var localLabel: UILabel!
    
    lazy var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var disposeBag = DisposeBag()
    
    let findustViewModel = FineDustViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocation()
        
        findustViewModel.observable
            .observe(on: MainScheduler.instance)
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
    
    func convertToAddressWith(coordinate: CLLocation){
        let geoCoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr") //원하는 언어의 나라 코드를 넣어주시면 됩니다.
        geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale, completionHandler: {(placemarks, error) in
            if let address: [CLPlacemark] = placemarks {
                guard let local_region = address.last?.administrativeArea
                , let local_city = address.last?.locality,
                      let local_sub = address.last?.subLocality else {
                    return
                }
                DispatchQueue.main.async {
                    self.localLabel.text = "\(local_region) \(local_city) \(local_sub)"
                }
            }
        })
    }
    
    func setLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            self.currentLocation = locationManager.location
            findustViewModel.getFineDust(lat: 127.95590235319048, lng: 37.375125349085906)
            convertToAddressWith(coordinate: CLLocation(latitude:37.375125349085906  , longitude: 127.95590235319048))
        }
    }
}
