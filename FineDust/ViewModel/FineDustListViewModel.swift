//
//  FineDustListViewModel.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/10.
//

import CoreLocation
import Foundation

import Alamofire
import RxSwift
import RxRelay
import SwiftyJSON

class FineDustList{
  static let shared = FineDustList()
  var fineDustList: [FineDustData] = []
  var storedFineDustList: [StoredFineDustData] = []
  var currentLocationFineDustAPIData: FineDustAPIData?
  var currentLocationLocationData: LocationData?
  var searchedFineDustAPIData: FineDustAPIData?
  var searchedLocationData: LocationData?
  private init(){}
}

class FineDustListViewModel{
  private var manager = FineDustList.shared
  lazy var observable = PublishRelay<[FineDustData]>()
  private let fineDustViewModel = FineDustViewModel()
  
  var fineDustListCount: Int{
    return manager.fineDustList.count
  }
  
  private var fineDustList: [FineDustData]{
    guard let currentLocationFineDustData = fineDustData(0, manager.currentLocationFineDustAPIData, manager.currentLocationLocationData) else { return [] }
    var list: [FineDustData] = [currentLocationFineDustData]
    sortFineDustList()
    list.append(contentsOf: manager.fineDustList)
    return list
  }
  
  func loadFineDustList(){
    manager.fineDustList = []
    _ = Observable.from(staionName())
      .flatMap{ station in APIService.loadFineDust(stationName: station)}
      .subscribe(onNext:{ [weak self] response in
        self?.addFineDustData(response)
      }, onCompleted: {
        self.observable.accept(self.fineDustList)
      })
  }
  
  private func staionName()-> [String]{
    var stationName: [String] = []
    manager.storedFineDustList.forEach{ i in
      stationName.append(i.stationName)
    }
    return stationName
  }
  
  func reloadFineDustList(){
    observable.accept(fineDustList)
  }
  
  private func fineDustData(_ timeStamp: Int, _ fineDustAPIData: FineDustAPIData?, _ locationData: LocationData?)-> FineDustData?{
    guard let fineDustAPIData = fineDustAPIData, let locationData = locationData else { return nil }
    return FineDustData(timeStamp: timeStamp, dateTime: fineDustAPIData.dateTime, fineDust: fineDustAPIData.fineDust, ultraFineDust: fineDustAPIData.ultraFineDust, stationName: fineDustAPIData.stationName, location: locationData)
  }
  
  private func sortFineDustList(){
    self.manager.fineDustList.sort{ $0.timeStamp > $1.timeStamp }
  }
  
  func setCurrentLocationFineDustAPIData(_ fineDustAPIData: FineDustAPIData){
    manager.currentLocationFineDustAPIData = fineDustAPIData
  }
  
  func setCurrentLocationLocationData(_ locationData: LocationData){
    manager.currentLocationLocationData = locationData
  }
  
  func setSearchedFineDustAPIData(_ fineDustAPIData: FineDustAPIData){
    manager.searchedFineDustAPIData = fineDustAPIData
  }
  
  func setSearchedLocationData(_ locationData: LocationData){
    manager.searchedLocationData = locationData
  }
  
  private func addFineDustData(_ fineDustAPIData: FineDustAPIData){
    guard let storedFineDustData = storedFineDustData(fineDustAPIData.stationName) else { return }
    let fineDustData = FineDustData(timeStamp: storedFineDustData.timeStamp , dateTime: fineDustAPIData.dateTime, fineDust: fineDustAPIData.fineDust, ultraFineDust: fineDustAPIData.ultraFineDust, stationName: fineDustAPIData.stationName, location: storedFineDustData.location)
    manager.fineDustList.append(fineDustData)
  }
  
  func addFineDustData(){
    guard let fineDustData = fineDustData(Int(Date().timeIntervalSince1970.rounded()), manager.searchedFineDustAPIData, manager.searchedLocationData) else { return }
    manager.fineDustList.append(fineDustData)
    saveFineDust()
  }
  
  func removeFineDust(_ i: Int){
    manager.fineDustList.remove(at: i)
    saveFineDust()
    reloadFineDustList()
  }
  
  func stationName(_ index: Int)-> String{
    return manager.fineDustList[index].stationName
  }
  
  func locationName(_ index: Int)-> String{
    return manager.fineDustList[index].location.locationName
  }
  
  private func storedFineDustData(_ stationName: String)-> StoredFineDustData?{
    for index in manager.storedFineDustList.indices{
      if manager.storedFineDustList[index].stationName == stationName{
        return manager.storedFineDustList[index]
      }
    }
    return nil
  }
  
  private func saveFineDust(){
    var storedFineDustList: [StoredFineDustData] = []
    manager.fineDustList.forEach{
      storedFineDustList.append(StoredFineDustData(timeStamp: $0.timeStamp, stationName: $0.stationName, location: $0.location))
    }
    Storage.store(storedFineDustList, to: .documents, as: "finedust.json")
    setUserDefaults()
  }
  
  private func setUserDefaults(){
    guard let stationName = manager.currentLocationFineDustAPIData?.stationName, let locationName = manager.currentLocationLocationData?.locationName else { return }
    let defaults = UserDefaults(suiteName: "group.com.sainkr.FineDust")
    defaults?.set(stationName, forKey: "stationName")
    defaults?.set(locationName, forKey: "locationName")
    defaults?.synchronize()
  }
  
  func loadFineDust(){
    let storefinedust = Storage.retrive("finedust.json", from: .documents, as: [StoredFineDustData].self) ?? []
    manager.storedFineDustList = storefinedust
  }
  
  func loadWidgetFineDust() -> [FineDustData]{
    /*let storefinedust = Storage.retrive("finedust.json", from: .documents, as: [StoredFineDustData].self) ?? []
    storedfinedust.forEach{
      
      /*FineDustListViewModel.finedustList.append(FineDustData(finedust: "-", finedustState: "-", finedustColor: .black, ultrafinedust: "-", ultrafinedustState: "-", ultrafinedustColor: .black, dateTime: "-", stationName: $0.stationName, currentLocation: $0.currentLocation, lat: $0.lat, lng: $0.lng, timeStamp: $0.timeStamp))*/
    }
    return manager.finedustList
     */
    return [] // 이거 걍 추가한거임
  }
}
