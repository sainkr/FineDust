//
//  ViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/05/25.
//
// 37.375125349085906, 127.95590235319048 // <tmX>284688.286381</tmX>// <tmY>431240.919844</tmY>

import CoreLocation
import UIKit
import MapKit

import RxSwift
import RxCocoa


class FineDustViewController: UIViewController {
  static let identifier = "FineDustViewController"
  
  @IBOutlet weak var locationNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var fineDustStateLabel: UILabel!
  @IBOutlet weak var fineDustValueLabel: UILabel!
  @IBOutlet weak var ultlraFineDustStateLabel: UILabel!
  @IBOutlet weak var ultraFineDustValueLabel: UILabel!
  @IBOutlet weak var fineDustProgressView: UIProgressView!
  @IBOutlet weak var ultraFineDustProgressView: UIProgressView!
  @IBOutlet weak var stationNameLabel: UILabel!
  @IBOutlet weak var navigationBar: UINavigationBar!
  @IBOutlet weak var refreshButton: UIButton!
  
  private let locationManager = LocationManager()
  private let fineDustViewModel = FineDustViewModel()
  private let currentLocationViewModel = CurrentLocationViewModel()
  private let fineDustListViewModel = FineDustListViewModel()
  private var time: Float = 0.0
  private var timer: Timer?
  private var currentLocation: CLLocation?
  private var disposeBag = DisposeBag()
  
  var index: Int = -1
  var mode: FineDustVCMode = .currentLocation
  var completeAddDelegate: CompleteAddDelegate?

  private let CompleteSearchNotification: Notification.Name = Notification.Name("CompleteSearchNotification")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Storage.clear(.documents)
    locationManager.locationMangerDelegate = self
    configureProgressView()
    locationNameLabel.text = " "
    dateLabel.text = " "
    
    setProgressView(nil)
    
    fineDustViewModel.observable
      .observe(on: MainScheduler.instance)
      .subscribe(onNext:{ [weak self] in
        self?.configureView($0)
        self?.setProgressView($0)
      })
      .disposed(by: disposeBag)
    
    currentLocationViewModel.observable
      .observe(on: MainScheduler.instance)
      .subscribe(onNext:{ [weak self] in
        self?.locationNameLabel.text = $0
      })
      .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    switch mode {
    case .currentLocation:
      // loadFineDust(latitude: 37.375125349085906, longtitude: 127.95590235319048)
      locationManager.requestLocation()
      refreshButton.isHidden = false
    case .added:
      loadFineDust(index)
    case .searched:
      navigationBar.isHidden = false
      NotificationCenter.default.addObserver(self, selector: #selector(completeSearch(_:)), name: CompleteSearchNotification, object: nil)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    disposeBag = DisposeBag()
    timer?.invalidate()
    NotificationCenter.default.removeObserver(self, name: CompleteSearchNotification, object: nil)
  }
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func addButtonDidTap(_ sender: Any) {
    fineDustListViewModel.addFineDustData()
    dismiss(animated: true, completion: {
      self.completeAddDelegate?.completeAdd()
    })
  }
  
  @IBAction func refreshButtonDidTap(_ sender: Any) {
    guard let coordinate = currentLocation?.coordinate else { return }
    loadFineDust(latitude: coordinate.latitude, longtitude: coordinate.longitude)
  }
}

extension FineDustViewController {
  private func configureView(_ fineDustAPIData: FineDustAPIData){
    dateLabel.text = fineDustAPIData.dateTime
    stationNameLabel.text = "\(fineDustAPIData.stationName) 측정소 기준\n제공 한국환경공단 에어코리아"
 
    fineDustStateLabel.textColor = fineDustAPIData.fineDust.fineDustColor
    fineDustValueLabel.textColor = fineDustAPIData.fineDust.fineDustColor
    fineDustStateLabel.text = fineDustAPIData.fineDust.fineDustState
    fineDustValueLabel.text = fineDustAPIData.fineDust.fineDustValue
    
    ultlraFineDustStateLabel.textColor = fineDustAPIData.ultraFineDust.ultraFineDustColor
    ultraFineDustValueLabel.textColor = fineDustAPIData.ultraFineDust.ultraFineDustColor
    ultlraFineDustStateLabel.text = fineDustAPIData.ultraFineDust.ultraFineDustState
    ultraFineDustValueLabel.text = fineDustAPIData.ultraFineDust.ultraFineDustValue
  }
  
  @objc func completeSearch(_ noti: Notification){ // 지역 추가했을 때
    guard let coordinate = noti.userInfo?["coordinate"] as? CLLocationCoordinate2D else { return }
    loadFineDust(latitude: coordinate.latitude, longtitude: coordinate.longitude)
  }
  
  private func loadFineDust(_ index: Int){
    fineDustViewModel.loadFineDust(stationName: fineDustListViewModel.stationName(index))
    locationNameLabel.text = fineDustListViewModel.locationName(index)
  }
  
  private func loadFineDust(latitude: Double, longtitude: Double){
    fineDustViewModel.loadFineDust(latitude: latitude, longtitude: longtitude, mode: mode)
    currentLocationViewModel.convertToAddress(latitude:latitude, longtitude: longtitude, mode: mode)
  }
  
  private func displayLocationServicesDisabledAlert() {
    let alertController = UIAlertController(title: "위치 권한 접근 오류",
                                            message: "미세먼지 앱의 위치 권한을 허용으로 바꿔주세요.",
                                            preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - LocationManagerDelegate
extension FineDustViewController: LocationManagerDelegate{
  func currentLocationUpdate(coordinate: CLLocationCoordinate2D) {
    loadFineDust(latitude: coordinate.latitude, longtitude: coordinate.longitude)
  }
  
  func currentLocationError() {
    displayLocationServicesDisabledAlert()
  }
}

// MARK: - Timer
extension FineDustViewController {
  private func configureProgressView(){
    fineDustProgressView.progressViewStyle = .bar
    fineDustProgressView.trackTintColor = #colorLiteral(red: 0.835541904, green: 0.8356826901, blue: 0.8355233073, alpha: 1)
    fineDustProgressView.clipsToBounds = true
    fineDustProgressView.layer.cornerRadius = 15
    fineDustProgressView.clipsToBounds = true
    fineDustProgressView.layer.sublayers![1].cornerRadius = 15
    fineDustProgressView.subviews[1].clipsToBounds = true
    fineDustProgressView.progress = 0.0
    
    ultraFineDustProgressView.progressViewStyle = .bar
    ultraFineDustProgressView.trackTintColor = #colorLiteral(red: 0.835541904, green: 0.8356826901, blue: 0.8355233073, alpha: 1)
    ultraFineDustProgressView.clipsToBounds = true
    ultraFineDustProgressView.layer.cornerRadius = 15
    ultraFineDustProgressView.clipsToBounds = true
    ultraFineDustProgressView.layer.sublayers![1].cornerRadius = 15
    ultraFineDustProgressView.subviews[1].clipsToBounds = true
    ultraFineDustProgressView.progress = 0.0
  }
  
  private func setProgressView(_ fineDustAPIData: FineDustAPIData?){
    timer?.invalidate()
    
    timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(setProgress(sender:)), userInfo: fineDustAPIData, repeats: true)
  }
  
  @objc func setProgress(sender: Timer) {
    guard let fineDustAPIData = sender.userInfo as? FineDustAPIData else { return }
    time += 0.01
    fineDustProgressView.progressTintColor = fineDustAPIData.fineDust.fineDustColor
    ultraFineDustProgressView.progressTintColor = fineDustAPIData.ultraFineDust.ultraFineDustColor
    
    let fineDustProgress = fineDustViewModel.calculatorFineDustValue(fineDustAPIData.fineDust.fineDustValue)
    let ultraFineDustProgress = fineDustViewModel.calculatorUltraFineDustValue(fineDustAPIData.ultraFineDust.ultraFineDustValue)
    if time <= fineDustProgress{
      fineDustProgressView.setProgress(time, animated: true)
    }
    if time <= ultraFineDustProgress{
      ultraFineDustProgressView.setProgress(time, animated: true)
    }
    
    if time > fineDustProgress && time > ultraFineDustProgress {
      time = 0.0
      timer!.invalidate()
    }
  }
}