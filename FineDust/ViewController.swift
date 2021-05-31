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

class ViewController: UIViewController {
    
    @IBOutlet weak var localLabel: UILabel!
    @IBOutlet weak var finedustLabel: UILabel!
    @IBOutlet weak var ultrafinedustLabel: UILabel!
    
    lazy var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var disposeBag = DisposeBag()
    
    let finedustViewModel = FineDustViewModel()
    let currentlocationViewModel = CurrentLocationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocation()
        
        finedustViewModel.observable
            .asDriver(onErrorJustReturn: FineDust(finedust: "-", ultrafinedust: "-"))
            .drive(onNext:{ [weak self] in
                self?.finedustLabel.text = $0.finedust
                self?.ultrafinedustLabel.text = $0.ultrafinedust
            })
            .disposed(by: disposeBag)
        
        currentlocationViewModel.locationName
            .asDriver(onErrorJustReturn: "현재 위치를 찾을 수 없습니다.")
            .drive(onNext:{ [weak self] in
                self?.localLabel.text = $0
                print("\($0)")
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
    
    func setLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            self.currentLocation = locationManager.location
            finedustViewModel.getFineDust(lat: 127.95590235319048, lng: 37.375125349085906)
            currentlocationViewModel.convertToAddressWith(coordinate: CLLocation(latitude:37.375125349085906  , longitude: 127.95590235319048))
        }
    }
    
    @IBAction func btnTapped(_ sender: Any) {
        setLocation()
    }
}
