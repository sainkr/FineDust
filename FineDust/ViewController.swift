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
    
    var finedustColor: UIColor?
    var ultrafinedustColor: UIColor?
    
    var findustValue: Int = 0
    var ultrafindustValue: Int = 0
    
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
        setLabel()
        
        finedustViewModel.observable
            .asDriver(onErrorJustReturn: FineDust(finedust: "-", ultrafinedust: "-"))
            .drive(onNext:{ [weak self] in
                self?.finedustColor = self?.setFineDustColor($0.finedust)
                self?.finedustSateLabel.textColor = self?.finedustColor
                self?.finedustLabel.textColor = self?.finedustColor
                self?.finedustSateLabel.text = self?.setFineDust($0.finedust)
                self?.finedustLabel.text = $0.finedust
                
                self?.ultrafinedustColor = self?.setUltraFineDustColor($0.ultrafinedust)
                self?.ultlrafinedustSateLabel.textColor = self?.ultrafinedustColor
                self?.ultrafinedustLabel.textColor = self?.ultrafinedustColor
                self?.ultlrafinedustSateLabel.text = self?.setUltraFineDust($0.ultrafinedust)
                self?.ultrafinedustLabel.text = $0.ultrafinedust
                
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
    
    @IBAction func btnTapped(_ sender: Any) {
        setLocation()
    }
}

extension ViewController{
    
    func setLabel(){
        let label = UILabel()
        
        label.text = "30"
        label.frame = CGRect(x: findustProgressView.frame.minX, y: findustProgressView.frame.minY , width: 20, height: 20)
        
    }
    func setProgressView(){
        
        if ((timer?.isValid) != nil){
            timer!.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
        
        findustProgressView.progressViewStyle = .bar
        findustProgressView.trackTintColor = .lightGray
        
        findustProgressView.clipsToBounds = true
        findustProgressView.layer.cornerRadius = 8
        findustProgressView.clipsToBounds = true
        findustProgressView.layer.sublayers![1].cornerRadius = 8
        findustProgressView.subviews[1].clipsToBounds = true
        
        findustProgressView.progress = 0.0
        
        ultraProgressView.progressViewStyle = .bar
        ultraProgressView.trackTintColor = .lightGray
        
        ultraProgressView.clipsToBounds = true
        ultraProgressView.layer.cornerRadius = 8
        ultraProgressView.clipsToBounds = true
        ultraProgressView.layer.sublayers![1].cornerRadius = 8
        ultraProgressView.subviews[1].clipsToBounds = true
        
        ultraProgressView.progress = 0.0

    }
    
    @objc func setProgress() {
        time += 0.1
        findustProgressView.progressTintColor = finedustColor
        ultraProgressView.progressTintColor = ultrafinedustColor
        
        if time <= (Float(findustValue) / 200){
            findustProgressView.setProgress((Float(findustValue) / 200), animated: true)
        }
        
        if time <= (Float(ultrafindustValue) / 100){
            ultraProgressView.setProgress((Float(ultrafindustValue) / 100), animated: true)
        }
        
        if time > (Float(findustValue) / 200) &&  time > (Float(ultrafindustValue) / 100) {
            timer!.invalidate()
        }
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
    
    func setFineDustColor(_ result: String) -> UIColor{
        guard let value = Int(result) else {
            return .black
        }
        
        findustValue = value
        
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
        
        ultrafindustValue = value
        
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
