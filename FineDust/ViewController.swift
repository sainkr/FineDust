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
    @IBOutlet weak var finedustSateLabel: UILabel!
    @IBOutlet weak var finedustLabel: UILabel!
    @IBOutlet weak var ultlrafinedustSateLabel: UILabel!
    @IBOutlet weak var ultrafinedustLabel: UILabel!
       
    lazy var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var disposeBag = DisposeBag()
    
    let finedustViewModel = FineDustViewModel()
    let currentlocationViewModel = CurrentLocationViewModel()
    
    let cellID = "FineDustCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocation()
        
        finedustViewModel.observable
            .asDriver(onErrorJustReturn: FineDust(finedust: "-", ultrafinedust: "-"))
            .drive(onNext:{ [weak self] in
                let finedustColor = self?.setFineDustColor($0.finedust)
                self?.finedustSateLabel.textColor = finedustColor
                self?.finedustLabel.textColor = finedustColor
                self?.finedustSateLabel.text = self?.setFineDust($0.finedust)
                self?.finedustLabel.text = $0.finedust
                
                let ultrafinedustColor = self?.setUltraFineDustColor($0.ultrafinedust)
                self?.ultlrafinedustSateLabel.textColor = ultrafinedustColor
                self?.ultrafinedustLabel.textColor = ultrafinedustColor
                self?.ultlrafinedustSateLabel.text = self?.setUltraFineDust($0.ultrafinedust)
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
    
    @IBAction func btnTapped(_ sender: Any) {
        setLocation()
    }
}

extension ViewController{
    func setLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            self.currentLocation = locationManager.location
            finedustViewModel.getFineDust(lat: 127.95590235319048, lng: 37.375125349085906)
            currentlocationViewModel.convertToAddressWith(coordinate: CLLocation(latitude:37.375125349085906  , longitude: 127.95590235319048))
        }
    }
    
    func setFineDustColor(_ result: String) -> UIColor{
        guard let value = Int(result) else {
            return .black
        }
        if value <= 30 {
            return .green
        }else if value <= 80 {
            return .blue
        }else if value <= 150 {
            return .red
        }else {
            return .red
        }
    }
    
    func setFineDust(_ result: String) -> String{
        // 미세먼지
        // 좋음 0~30
        // 보통 ~80
        // 나쁨 ~150
        // 매우나쁨 151~
        guard let value = Int(result) else {
            return "-"
        }
        
        if value <= 30 {
            return "좋음"
        }else if value <= 80 {
            return "보통"
        }else if value <= 150 {
            return "나쁨"
        }else {
            return "매우 나쁨"
        }
    }
    
    func setUltraFineDustColor(_ result: String) -> UIColor{
        guard let value = Int(result) else {
            return .black
        }
        if value <= 15 {
            return .green
        }else if value <= 35 {
            return .blue
        }else if value <= 70 {
            return .red
        }else {
            return .red
        }
    }
    
    func setUltraFineDust(_ result: String) -> String{
        // 초미세먼지
        // 좋음 0~15
        // 보통 ~35
        // 나쁨 ~70
        // 매우나쁨 76~
        guard let value = Int(result) else {
            return "-"
        }
        
        if value <= 15 {
            return "좋음"
        }else if value <= 35 {
            return "보통"
        }else if value <= 70 {
            return "나쁨"
        }else {
            return "매우 나쁨"
        }
    }
}
