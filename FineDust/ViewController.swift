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
    
    lazy var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    let disposeBag = DisposeBag()
    
    let findustViewModel = FineDustViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocation()
    }
    
    func setLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            self.currentLocation = locationManager.location
            findustViewModel.getFineDust(lat: currentLocation.coordinate.longitude, lng: currentLocation.coordinate.latitude)
        }
    }
}
