//
//  FineDustViewModel.swift
//  FineDust
//
//  Created by 홍승아 on 2021/05/27.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire
import SwiftyJSON
import CoreLocation

class FineDustViewModel{
  lazy var observable = PublishRelay<FineDustAPIData>()
  
  // 현재 위치 fineDustData, 검색 위치 fineDustData 불러옴
  func loadFineDust(latitude: Double, longtitude: Double, mode: FineDustVCMode){
    _ = APIService.loadTM(latitude: latitude, longtitude: longtitude)
      .flatMap{ tm in APIService.loadStation(tmX: tm.tmX, tmY: tm.tmY)}
      .flatMap{ station in APIService.loadFineDust(stationName: station)}
      .take(1)
      .subscribe(onNext:{ [weak self] response in
        self?.observable.accept(response)
        self?.setAPIData(mode, response)
      })
  }
  
  private func setAPIData(_ mode: FineDustVCMode, _ response: FineDustAPIData){
    let fineDustListViewModel = FineDustListViewModel()
    if mode == .currentLocation {
      fineDustListViewModel.setCurrentLocationFineDustAPIData(response)
    }else if mode == .searched {
      fineDustListViewModel.setSearchedFineDustAPIData(response)
    }
  }
  
  // 추가된 fineDustData 불러옴
  func loadFineDust(stationName: String){
    _ = APIService.loadFineDust(stationName: stationName)
      .take(1)
      .subscribe(onNext:{ [weak self] response in
        self?.observable.accept(response)
      })
  }
  
  // Widget 현재 위치 fineDust
  func loadFineDust(latitude: Double, longtitude: Double, completion: @escaping (FineDustRequest) -> ()){
    _ = APIService.loadTM(latitude: latitude, longtitude: longtitude)
      .flatMap{ tm in APIService.loadStation(tmX: tm.tmX, tmY: tm.tmY)}
      .flatMap{ station in APIService.loadFineDust(stationName: station)}
      .take(1)
      .subscribe(onNext:{ [weak self] response in
        completion((self?.fineDustRequest(apiFineDust: response))!)
      })
  }
    
  private func fineDustRequest(apiFineDust: FineDustAPIData)-> FineDustRequest{
    return FineDustRequest(locationName: "-", fineDust: apiFineDust.fineDust, ultraFineDust: apiFineDust.ultraFineDust)
  }
  
  func fineDust(_ fineDustValue: String)-> FineDust{
    return FineDust(fineDustValue: fineDustValue,
                    fineDustState: setFineDust(fineDustValue),
                    fineDustColor: setFineDustColor(fineDustValue))
  }
  
  func ultraFineDust(_ ultraFineDustValue: String)-> UltraFineDust{
    return UltraFineDust(ultraFineDustValue: ultraFineDustValue,
                         ultraFineDustState: setUltraFineDust(ultraFineDustValue),
                         ultraFineDustColor: setUltraFineDustColor(ultraFineDustValue))
  }
  
  private func setFineDustColor(_ result: String) -> UIColor{
    guard let value = Int(result) else {
      return .black
    }
    if value <= 30 {
      return #colorLiteral(red: 0.1309628189, green: 0.6049023867, blue: 1, alpha: 1)
    }else if value <= 80 {
      return #colorLiteral(red: 0.08792158216, green: 0.7761771083, blue: 0.2295451164, alpha: 1)
    }else if value <= 150 {
      return #colorLiteral(red: 0.9908027053, green: 0.6055337787, blue: 0.3520092368, alpha: 1)
    }else {
      return #colorLiteral(red: 1, green: 0.3110373616, blue: 0.312485069, alpha: 1)
    }
  }
  
  private func setFineDust(_ result: String) -> String{
    // 미세먼지 // 좋음 0~30 // 보통 ~80 // 나쁨 ~150 // 매우나쁨 151~
    guard let value = Int(result) else { return "-" }
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
  
  private func setUltraFineDustColor(_ result: String) -> UIColor{
    guard let value = Int(result) else { return .black }
    if value <= 15 {
      return #colorLiteral(red: 0.1309628189, green: 0.6049023867, blue: 1, alpha: 1)
    }else if value <= 35 {
      return #colorLiteral(red: 0.08792158216, green: 0.7761771083, blue: 0.2295451164, alpha: 1)
    }else if value <= 70 {
      return #colorLiteral(red: 0.9908027053, green: 0.6055337787, blue: 0.3520092368, alpha: 1)
    }else {
      return #colorLiteral(red: 1, green: 0.3110373616, blue: 0.312485069, alpha: 1)
    }
  }
  
  private func setUltraFineDust(_ result: String) -> String{
    // 초미세먼지 // 좋음 0~15 // 보통 ~35 // 나쁨 ~70 // 매우나쁨 76~
    guard let value = Int(result) else { return "-"}
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
  
  func calculatorFineDustValue(_ value: String) -> Float{
    guard let value = Int(value) else { return 0 }
    if value < 30{
      return round(Float(value) * 25 / Float(30)) / 100
    }else if value == 30 {
      return 0.25
    }else if value < 80 {
      return round(Float(value) * 25 / Float(80)) / 100 + 0.25
    }else if value == 80 {
      return 0.5
    }else if value < 150{
      return round(Float(value) * 25 / Float(150)) / 100 + 0.5
    }else if value == 150{
      return 0.75
    }else if value < 200{
      return round(Float(value) * 25 / Float(30)) / 100 + 0.75
    }else{
      return 1.0
    }
  }
  
  func calculatorUltraFineDustValue(_ value: String) -> Float{
    guard let value = Int(value) else { return 0 }
    if value < 15{
      return round(Float(value) * 25 / Float(15)) / 100
    }else if value == 15 {
      return 0.25
    }else if value < 35 {
      return round(Float(value) * 25 / Float(35)) / 100 + 0.25
    }else if value == 35 {
      return 0.5
    }else if value < 75{
      return round(Float(value) * 25 / Float(75)) / 100 + 0.5
    }else if value == 150{
      return 0.75
    }else if value < 100{
      return round(Float(value) * 25 / Float(100)) / 100 + 0.75
    }else{
      return 1.0
    }
  }
}
