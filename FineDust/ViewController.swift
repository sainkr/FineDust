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
    @IBOutlet weak var findustProgressView: UIProgressView!
    @IBOutlet weak var ultraProgressView: UIProgressView!
    @IBOutlet weak var stationLabel: UILabel!
    
    var finedustColor: UIColor?
    var ultrafinedustColor: UIColor?
    
    var time: Float = 0.0
    var timer: Timer?
    
    lazy var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var disposeBag = DisposeBag()
    
    let finedustViewModel = FineDustViewModel()
    let currentlocationViewModel = CurrentLocationViewModel()
    
    let cellID = "FineDustCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProgressView()
        setLocation()
        
        finedustViewModel.observable
            .asDriver(onErrorJustReturn: FineDust(finedust: "-", ultrafinedust: "-", stationName: "-", dateTime: "-"))
            .drive(onNext:{ [weak self] in
                self?.finedustColor = self?.finedustViewModel.setFineDustColor($0.finedust)
                self?.finedustSateLabel.textColor = self?.finedustColor
                self?.finedustLabel.textColor = self?.finedustColor
                self?.finedustSateLabel.text = self?.finedustViewModel.setFineDust($0.finedust)
                self?.finedustLabel.text = $0.finedust
                
                self?.ultrafinedustColor = self?.finedustViewModel.setUltraFineDustColor($0.ultrafinedust)
                self?.ultlrafinedustSateLabel.textColor = self?.ultrafinedustColor
                self?.ultrafinedustLabel.textColor = self?.ultrafinedustColor
                self?.ultlrafinedustSateLabel.text = self?.finedustViewModel.setUltraFineDust($0.ultrafinedust)
                self?.ultrafinedustLabel.text = $0.ultrafinedust
                
                self?.stationLabel.text = "\($0.stationName) 측정소 기준\n제공 한국환경공단 에어코리아"
                self?.setProgressView()
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
    
    func setProgressView(){
        if ((timer?.isValid) != nil){
            timer!.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
        
        findustProgressView.progressViewStyle = .bar
        findustProgressView.trackTintColor = .lightGray
        
        findustProgressView.clipsToBounds = true
        findustProgressView.layer.cornerRadius = 15
        findustProgressView.clipsToBounds = true
        findustProgressView.layer.sublayers![1].cornerRadius = 15
        findustProgressView.subviews[1].clipsToBounds = true
        
        findustProgressView.progress = 0.0
        
        ultraProgressView.progressViewStyle = .bar
        ultraProgressView.trackTintColor = .lightGray
        
        ultraProgressView.clipsToBounds = true
        ultraProgressView.layer.cornerRadius = 15
        ultraProgressView.clipsToBounds = true
        ultraProgressView.layer.sublayers![1].cornerRadius = 15
        ultraProgressView.subviews[1].clipsToBounds = true
        
        ultraProgressView.progress = 0.0
        
    }
    
    @objc func setProgress() {
        time += 0.1
        findustProgressView.progressTintColor = finedustColor
        ultraProgressView.progressTintColor = ultrafinedustColor
        
        guard let finedustValue = Int(finedustViewModel.currentFineDust.finedust) else { return }
        guard let ultrafindustValue = Int(finedustViewModel.currentFineDust.ultrafinedust) else { return }
        
        if time <= finedustViewModel.calculatorFineDust(finedustValue){
            findustProgressView.setProgress(time, animated: true)
        }
        
        if time <= finedustViewModel.calculatorUltraFineDust(ultrafindustValue){
            ultraProgressView.setProgress(time, animated: true)
        }
        
        if time > finedustViewModel.calculatorFineDust(finedustValue) &&  time > finedustViewModel.calculatorUltraFineDust(ultrafindustValue) {
            timer!.invalidate()
        }
    }
    
}
