//
//  ViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/05/25.
//

import CoreLocation
import UIKit
import MapKit

import RxSwift
import RxCocoa

class FineDustViewController: UIViewController{
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
  private var currentLocation: CLLocation?
  private var disposeBag = DisposeBag()
  private var fineDustCurrentProgress: Float = 0.0
  private var ultraFineDustCurrentProgress: Float = 0.0
  private var fineDustProgressTimer: Timer?
  private var ultraFineDustProgressTimer: Timer?
  private var fineDustProgress: Float = 0.0
  private var ultraFineDustProgress: Float = 0.0
  private var progressViewStyle: UIProgressView.Style = .bar
  
  var index: Int = -1
  var mode: FineDustVCMode = .currentLocation
  var completeAddDelegate: CompleteAddDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.locationMangerDelegate = self
    
    locationNameLabel.text = " "
    dateLabel.text = " "
  
    configureProgressView()
    
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
        print($0)
        self?.locationNameLabel.text = $0
      })
      .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    switch mode {
    case .currentLocation:
      locationManager.requestLocation()
      refreshButton.isHidden = false
    case .added:
      loadFineDust(index)
    case .searched:
      navigationBar.isHidden = false
      NotificationCenter.default.addObserver(self, selector: #selector(completeSearch(_:)), name: NotificationName.CompleteSearchNotification, object: nil)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    disposeBag = DisposeBag()
    fineDustProgressTimer?.invalidate()
    ultraFineDustProgressTimer?.invalidate()
    if mode == .searched {
      NotificationCenter.default.removeObserver(self, name: NotificationName.CompleteSearchNotification, object: nil)
    }
  }
}

extension FineDustViewController{
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
  
  @objc func completeSearch(_ noti: Notification){ // SearchLocationViewController 에서 불러옴
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
                                            message: "위치 접근 허용을 앱 또는 위젯을 사용하는 동안으로 바꿔주세요.",
                                            preferredStyle: .alert)
    let okAction = UIAlertAction(title: "확인", style: .default){ _ in
      guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
      }
    }
    alertController.addAction(okAction)
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - IBAction
extension FineDustViewController{
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
    guard let coordinate = currentLocation?.coordinate else {
      return }
    progressViewStyle = progressViewStyle == .bar ? .default : .bar
    loadFineDust(latitude: coordinate.latitude, longtitude: coordinate.longitude)
  }
}

// MARK: - LocationManagerDelegate
extension FineDustViewController: LocationManagerDelegate{
  func currentLocationUpdate(coordinate: CLLocationCoordinate2D) {
    currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    loadFineDust(latitude: coordinate.latitude, longtitude: coordinate.longitude)
  }
  
  func currentLocationError() {
    displayLocationServicesDisabledAlert()
  }
}

// MARK: - Timer
extension FineDustViewController{
  private func configureProgressView(){
    fineDustProgressView.trackTintColor = #colorLiteral(red: 0.835541904, green: 0.8356826901, blue: 0.8355233073, alpha: 1)
    fineDustProgressView.clipsToBounds = true
    fineDustProgressView.layer.cornerRadius = 15
    fineDustProgressView.layer.sublayers![1].cornerRadius = 15
    fineDustProgressView.subviews[1].clipsToBounds = true
    fineDustProgressView.progress = 0.0
    
    ultraFineDustProgressView.trackTintColor = #colorLiteral(red: 0.835541904, green: 0.8356826901, blue: 0.8355233073, alpha: 1)
    ultraFineDustProgressView.clipsToBounds = true
    ultraFineDustProgressView.layer.cornerRadius = 15
    ultraFineDustProgressView.layer.sublayers![1].cornerRadius = 15
    ultraFineDustProgressView.subviews[1].clipsToBounds = true
    ultraFineDustProgressView.progress = 0.0
  }
  
  private func setProgressView(_ fineDustAPIData: FineDustAPIData){
    fineDustProgress = fineDustViewModel.calculatorFineDustValue(fineDustAPIData.fineDust.fineDustValue)
    ultraFineDustProgress = fineDustViewModel.calculatorUltraFineDustValue(fineDustAPIData.ultraFineDust.ultraFineDustValue)
    fineDustProgressView.progressViewStyle = progressViewStyle
    ultraFineDustProgressView.progressViewStyle = progressViewStyle
    fineDustProgressView.progressTintColor = fineDustAPIData.fineDust.fineDustColor
    ultraFineDustProgressView.progressTintColor = fineDustAPIData.ultraFineDust.ultraFineDustColor
    setTimer()
  }
  
  private func setTimer(){
    fineDustProgressTimer?.invalidate()
    ultraFineDustProgressTimer?.invalidate()
    fineDustProgressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(setFineDustProgress(sender:)), userInfo: nil, repeats: true)
    ultraFineDustProgressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(setUltraFineDustProgress(sender:)), userInfo: nil, repeats: true)
  }

  @objc func setFineDustProgress(sender: Timer) {
    if fineDustCurrentProgress < fineDustProgress{
      fineDustCurrentProgress += 0.01
    }else if fineDustCurrentProgress > fineDustProgress {
      fineDustCurrentProgress -= 0.01
    }
    fineDustProgressView.setProgress(fineDustCurrentProgress, animated: true)
    if isProgressEnd(fineDustCurrentProgress, fineDustProgress){
      fineDustProgressTimer?.invalidate()
    }
  }
  
  @objc func setUltraFineDustProgress(sender: Timer) {
    if ultraFineDustCurrentProgress < ultraFineDustProgress{
      ultraFineDustCurrentProgress += 0.01
    }else if ultraFineDustCurrentProgress > ultraFineDustProgress{
      ultraFineDustCurrentProgress -= 0.01
    }
    ultraFineDustProgressView.setProgress(ultraFineDustCurrentProgress, animated: true)
    if isProgressEnd(ultraFineDustCurrentProgress, ultraFineDustProgress){
      ultraFineDustProgressTimer?.invalidate()
    }
  }
  
  private func isProgressEnd(_ currentValue: Float, _ value: Float)-> Bool{
    if round(currentValue * 100) / 100 == value{
      return true
    }
    return false
  }
}
