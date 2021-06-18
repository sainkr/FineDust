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
import MapKit

// 37.375125349085906, 127.95590235319048
// <tmX>284688.286381</tmX>
// <tmY>431240.919844</tmY>

class ViewController: UIViewController {
    
    enum VCMode: String {
        case main
        case add
        case show
    }
    
    @IBOutlet weak var localLabel: UILabel!
    @IBOutlet weak var finedustSateLabel: UILabel!
    @IBOutlet weak var finedustLabel: UILabel!
    @IBOutlet weak var ultlrafinedustSateLabel: UILabel!
    @IBOutlet weak var ultrafinedustLabel: UILabel!
    @IBOutlet weak var findustProgressView: UIProgressView!
    @IBOutlet weak var ultraProgressView: UIProgressView!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var listButton: UIButton!
    
    var finedustColor: UIColor?
    var ultrafinedustColor: UIColor?
    
    var time: Float = 0.0
    var timer: Timer?
    
    lazy var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var disposeBag = DisposeBag()
    
    let finedustViewModel = FineDustViewModel()
    let currentlocationViewModel = CurrentLocationViewModel()
    let finedustListViewModel = FineDustListViewModel()
    
    let cellID = "FineDustCell"

    var location: CLLocationCoordinate2D?
    var index: Int = 0
    var mode: VCMode = .main
    
    var currentFinedust: FineDust?

    let CompleteSearchNotification: Notification.Name = Notification.Name("CompleteSearchNotification")
    let CompleteAddNotification: Notification.Name = Notification.Name("CompleteAddNotification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentFinedust = finedustViewModel.errorFineDust

        NotificationCenter.default.addObserver(self, selector: #selector(didReciveNotification(_:)), name: CompleteSearchNotification, object: nil)
        
        setProgressView(nil)
        setPageControl()
        
        locationManager.delegate = self
        
        finedustViewModel.observable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext:{ [weak self] in
               
                self?.finedustColor = $0.finedustColor
                self?.finedustSateLabel.textColor = $0.finedustColor
                self?.finedustLabel.textColor = $0.finedustColor
                self?.finedustSateLabel.text = $0.finedustState
                self?.finedustLabel.text = $0.finedust
                
                self?.ultrafinedustColor = $0.ultrafinedustColor
                self?.ultlrafinedustSateLabel.textColor = $0.ultrafinedustColor
                self?.ultrafinedustLabel.textColor = $0.ultrafinedustColor
                self?.ultlrafinedustSateLabel.text = $0.ultrafinedustState
                self?.ultrafinedustLabel.text = $0.ultrafinedust
                
                self?.stationLabel.text = "\($0.stationName) 측정소 기준\n제공 한국환경공단 에어코리아"
                self?.setProgressView($0)
                
                if self?.mode == .main{
                    self?.finedustListViewModel.addCurrentLocationFineDust($0)
                }else if self?.mode == .add{
                    if self?.currentFinedust == nil {
                        self?.currentFinedust = $0
                    }
                    self?.currentFinedust?.finedust = $0.finedust
                    self?.currentFinedust?.finedustState = $0.finedustState
                    self?.currentFinedust?.finedustColor = $0.finedustColor
                    self?.currentFinedust?.ultrafinedust = $0.ultrafinedust
                    self?.currentFinedust?.ultrafinedustState = $0.ultrafinedustState
                    self?.currentFinedust?.ultrafinedustColor = $0.ultrafinedustColor
                    self?.currentFinedust?.dateTime = $0.dateTime
                    self?.currentFinedust?.stationName = $0.stationName
                    self?.currentFinedust?.lat = $0.lat
                    self?.currentFinedust?.lng = $0.lng
                    self?.currentFinedust?.timeStamp = $0.timeStamp
                }
            })
            .disposed(by: disposeBag)
        
        currentlocationViewModel.locationName
            .asDriver(onErrorJustReturn: "현재 위치를 찾을 수 없습니다.")
            .drive(onNext:{ [weak self] in
                self?.localLabel.text = $0
                if self?.mode == .main{
                    self?.finedustListViewModel.addCurrentLocationFineDust($0)
                }else if self?.mode == .add{
                    self?.currentFinedust?.currentLocation = $0
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mode == .add{
            navigationBar.isHidden = false
            pageControl.isHidden = true
            listButton.isHidden = true
        }
        else if mode == .show{
            show(index)
        }
        else {
            finedustViewModel.getFineDust( lat: 37.375125349085906, lng: 127.95590235319048, timeStamp: 2147483647)
            currentlocationViewModel.convertToAddressWith(coordinate: CLLocation(latitude:37.375125349085906 , longitude: 127.95590235319048))
            // requestLocation()
        }
    }
    
    func show(_ index: Int){
        let finedust = FineDustListViewModel.finedustList[index]
        finedustViewModel.getFineDust(finedust: finedust)
        currentlocationViewModel.convertToAddressWith(coordinate: CLLocation(latitude: finedust.lat, longitude: finedust.lng))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
        timer?.invalidate()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        if var finedust = currentFinedust, let lat = location?.latitude, let lng = location?.longitude{
            finedust.lat = lat
            finedust.lng = lng
            finedustListViewModel.addFineDust(finedust)
            dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: self.CompleteAddNotification, object: nil)
            })
        }
    }
    
    @IBAction func pagecontrolChanged(_ sender: Any) {
        show(pageControl.currentPage)
    }
    
    @objc func didReciveNotification(_ noti: Notification){
        guard let coordinate = noti.userInfo?["coordinate"] as? CLLocationCoordinate2D else { return }
        location = coordinate
        getFineDust(coordinate.latitude, coordinate.longitude)
    }
}

// MARK: - Location Handling

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Location data received.")
            print(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get users location.")
    }
        
        
    private func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            displayLocationServicesDisabledAlert()
            return
        }
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.currentLocation = locationManager.location
        
        getFineDust(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
    }
    
    private func getFineDust(_ lat: Double, _ lng: Double){
        finedustViewModel.getFineDust(lat: lat, lng: lng, timeStamp: Int(Date().timeIntervalSince1970.rounded()))
        currentlocationViewModel.convertToAddressWith(coordinate: CLLocation(latitude:lat , longitude: lng))
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

// MARK: - UI

extension ViewController{
    
    func setPageControl(){
        view.isUserInteractionEnabled = true
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swipeRight)
        
        pageControl.numberOfPages = FineDustListViewModel.finedustList.count
        pageControl.currentPage = index
        
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction{
                case UISwipeGestureRecognizer.Direction.left :
                    mode = .show
                    if pageControl.currentPage < FineDustListViewModel.finedustList.count - 1{
                        pageControl.currentPage += 1
                        show(pageControl.currentPage)
                    }
                case UISwipeGestureRecognizer.Direction.right :
                    mode = .show
                    if pageControl.currentPage > 0{
                        pageControl.currentPage -= 1
                        show(pageControl.currentPage)
                    }
                default:
                    break
            }
        }
    }
    
    func setProgressView(_ finedust: FineDust?){
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(setProgress(sender:)), userInfo: finedust, repeats: true)
        
        findustProgressView.progressViewStyle = .bar
        findustProgressView.trackTintColor = #colorLiteral(red: 0.835541904, green: 0.8356826901, blue: 0.8355233073, alpha: 1)
        
        findustProgressView.clipsToBounds = true
        findustProgressView.layer.cornerRadius = 15
        findustProgressView.clipsToBounds = true
        findustProgressView.layer.sublayers![1].cornerRadius = 15
        findustProgressView.subviews[1].clipsToBounds = true
        
        findustProgressView.progress = 0.0
        
        ultraProgressView.progressViewStyle = .bar
        ultraProgressView.trackTintColor = #colorLiteral(red: 0.835541904, green: 0.8356826901, blue: 0.8355233073, alpha: 1)
        
        ultraProgressView.clipsToBounds = true
        ultraProgressView.layer.cornerRadius = 15
        ultraProgressView.clipsToBounds = true
        ultraProgressView.layer.sublayers![1].cornerRadius = 15
        ultraProgressView.subviews[1].clipsToBounds = true
        
        ultraProgressView.progress = 0.0
    }
    
    @objc func setProgress(sender: Timer) {
        guard let finedust = sender.userInfo as? FineDust else { return }
        
        let finedustValue = Int(finedust.finedust)!
        let ultrafindustValue = Int(finedust.ultrafinedust)!
        
        time += 0.01
        findustProgressView.progressTintColor = finedustColor
        ultraProgressView.progressTintColor = ultrafinedustColor
        
        if time <= finedustViewModel.calculatorFineDust(finedustValue){
            findustProgressView.setProgress(time, animated: true)
        }
        if time <= finedustViewModel.calculatorUltraFineDust(ultrafindustValue){
            ultraProgressView.setProgress(time, animated: true)
        }
        
        if time > finedustViewModel.calculatorFineDust(finedustValue) &&  time > finedustViewModel.calculatorUltraFineDust(ultrafindustValue) {
            // print(finedustViewModel.calculatorFineDust(finedustValue))
            // print(finedustViewModel.calculatorUltraFineDust(ultrafindustValue))
            time = 0.0
            timer!.invalidate()
        }
    }
    
}
