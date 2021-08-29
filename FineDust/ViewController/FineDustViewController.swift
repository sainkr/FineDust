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
import WidgetKit

import RxSwift
import RxCocoa

class FineDustViewController: UIViewController {
  
  enum FineDustVCMode{
    case currentLocation
    case searched
    case added
  }
  
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
  
  private var time: Float = 0.0
  private var timer: Timer?
  
  lazy var locationManager = CLLocationManager()
  var currentLocation: CLLocation!
  
  private var disposeBag = DisposeBag()
  
  private let fineDustViewModel = FineDustViewModel()
  private let currentLocationViewModel = CurrentLocationViewModel()
  private let fineDustListViewModel = FineDustListViewModel()

  var index: Int = -1
  var mode: FineDustVCMode = .currentLocation

  private let CompleteSearchNotification: Notification.Name = Notification.Name("CompleteSearchNotification")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureProgressView()
    locationNameLabel.text = ""
    dateLabel.text = ""
    
    NotificationCenter.default.addObserver(self, selector: #selector(didReciveNotification(_:)), name: CompleteSearchNotification, object: nil)
    
    setProgressView(nil)
    
    fineDustViewModel.observable
      .observe(on: MainScheduler.instance)
      .subscribe(onNext:{ [weak self] in
        print($0)
        self?.configureView($0)
        self?.setProgressView($0)
        if self?.mode == .currentLocation {
          self?.fineDustListViewModel.setCurrentLocationFineDustAPIData($0)
        }else if self?.mode == .searched {
          self?.fineDustListViewModel.setSearchedFineDustAPIData($0)
        }
      })
      .disposed(by: disposeBag)
    
    currentLocationViewModel.observable
      .observe(on: MainScheduler.instance)
      .subscribe(onNext:{ [weak self] in
        self?.locationNameLabel.text = $0.locationName
        if self?.mode == .currentLocation {
          self?.fineDustListViewModel.setCurrentLocationLocationData($0)
        }else if self?.mode == .searched {
          self?.fineDustListViewModel.setSearchedLocationData($0)
        }
      })
      .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    switch mode {
    case .currentLocation:
      loadFineDust(latitude: 37.375125349085906, longtitude: 127.95590235319048)
      // requestLocation()
      break
    case .added:
      loadFineDust(index)
    case .searched:
      navigationBar.isHidden = false
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    disposeBag = DisposeBag()
    timer?.invalidate()
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func addButtonTapped(_ sender: Any) {
    fineDustListViewModel.addFineDustData()
    dismiss(animated: true, completion: nil)
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
  
  @objc func didReciveNotification(_ noti: Notification){ // 지역 추가했을 때
    guard let coordinate = noti.userInfo?["coordinate"] as? CLLocationCoordinate2D else { return }
    loadFineDust(latitude: coordinate.latitude, longtitude: coordinate.longitude)
  }
  
  private func loadFineDust(_ index: Int){
    fineDustViewModel.loadFineDust(stationName: fineDustListViewModel.stationName(index))
    locationNameLabel.text = fineDustListViewModel.locationName(index)
  }
  
  private func loadFineDust(latitude: Double, longtitude: Double){
    fineDustViewModel.loadFineDust(latitude: latitude, longtitude: longtitude)
    currentLocationViewModel.convertToAddress(latitude:latitude, longtitude: longtitude)
  }
}

// MARK: - Location Handling
extension FineDustViewController : CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus == .authorizedWhenInUse {
      self.currentLocation = locationManager.location
      loadFineDust(latitude: currentLocation.coordinate.latitude, longtitude: currentLocation.coordinate.longitude)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to get users location.")
  }
  
  private func requestLocation() {
    locationManager.delegate = self
    
    guard CLLocationManager.locationServicesEnabled() else {
      displayLocationServicesDisabledAlert()
      return
    }
    
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  private func displayLocationServicesDisabledAlert() {
    let message = NSLocalizedString("LOCATION_SERVICES_DISABLED", comment: "Location services are disabled")
    let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                            message: message,
                                            preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: "OK alert button"), style: .default, handler: nil))
    present(alertController, animated: true, completion: nil)
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
