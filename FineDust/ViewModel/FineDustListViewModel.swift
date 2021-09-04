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

class FineDustListViewModel{
  private var manager = FineDustList.shared
  lazy var observable = PublishRelay<[FineDustData]>()
  private let fineDustViewModel = FineDustViewModel()
    
  private var fineDustList: [FineDustData]{
    guard let currentLocationFineDustData = fineDustData(0, manager.currentLocationFineDustAPIData, manager.currentLocationLocationData) else { return [] }
    var list: [FineDustData] = [currentLocationFineDustData]
    sortFineDustList()
    list.append(contentsOf: manager.fineDustList)
    return list
  }
  
  var fineDustListCount: Int{
    if manager.fineDustList.count == 0 {
      return 1
    }
    return manager.fineDustList.count + 1
  }
  
  func loadFineDustList(){
    _ = Observable.from(staionName())
      .flatMap{ station in APIService.loadFineDust(stationName: station)}
      .subscribe(onNext:{ [weak self] response in
        self?.setFineDustList(response)
      }, onCompleted: {
        self.observable.accept(self.fineDustList)
      })
  }
  
  private func staionName()-> [String]{
    var stationName: [String] = []
    manager.fineDustList.forEach{ i in
      stationName.append(i.stationName)
    }
    return stationName
  }
  
  func reloadFineDustList(){
    observable.accept(fineDustList)
  }
  
  private func fineDustData(_ timeStamp: Int, _ fineDustAPIData: FineDustAPIData?, _ locationData: LocationData?)-> FineDustData?{
    guard let locationData = locationData else { return nil }
    guard let fineDustAPIData = fineDustAPIData else {
      reloadFineDustList()
      return nil
    }
    return FineDustData(timeStamp: timeStamp, dateTime: fineDustAPIData.dateTime, fineDust: fineDustAPIData.fineDust, ultraFineDust: fineDustAPIData.ultraFineDust, stationName: fineDustAPIData.stationName, location: locationData)
  }
  
  private func sortFineDustList(){
    self.manager.fineDustList.sort{ $0.timeStamp < $1.timeStamp }
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
  
  private func setFineDustList(_ fineDustAPIData: FineDustAPIData){
    for index in manager.fineDustList.indices{
      if manager.fineDustList[index].stationName == fineDustAPIData.stationName {
        let fineDustData = FineDustData(timeStamp: manager.fineDustList[index].timeStamp , dateTime: fineDustAPIData.dateTime, fineDust: fineDustAPIData.fineDust, ultraFineDust: fineDustAPIData.ultraFineDust, stationName: fineDustAPIData.stationName, location: manager.fineDustList[index].location)
        manager.fineDustList[index] = fineDustData
      }
    }
  }
  
  func addFineDustData(){
    guard let fineDustData = fineDustData(Int(Date().timeIntervalSince1970.rounded()), manager.searchedFineDustAPIData, manager.searchedLocationData) else { return }
    manager.fineDustList.append(fineDustData)
    saveFineDust()
  }
  
  func removeFineDust(_ i: Int){
    manager.fineDustList.remove(at: i - 1)
    saveFineDust()
    reloadFineDustList()
  }
  
  func stationName(_ index: Int)-> String{
    return manager.fineDustList[index - 1].stationName
  }
  
  func locationName(_ index: Int)-> String{
    return manager.fineDustList[index - 1].location.locationName
  }
  
  private func saveFineDust(){
    var storedFineDustList: [StoredFineDustData] = []
    manager.fineDustList.forEach{
      storedFineDustList.append(StoredFineDustData(timeStamp: $0.timeStamp, stationName: $0.stationName, location: $0.location))
    }
    Storage.store(storedFineDustList, to: .documents, as: "finedust.json")
  }
  
  func loadFineDust(){
    let storefinedust = Storage.retrive("finedust.json", from: .documents, as: [StoredFineDustData].self) ?? []
    storefinedust.forEach{
      manager.fineDustList.append(FineDustData(timeStamp: $0.timeStamp, dateTime: "-", fineDust: fineDustViewModel.fineDust("-"), ultraFineDust: fineDustViewModel.ultraFineDust("-"), stationName: $0.stationName, location: $0.location))
    }
    
    // loadFineDustList()
  }
}
