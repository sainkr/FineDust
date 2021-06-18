//
//  FineDustListViewModel.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/10.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire
import SwiftyJSON
import CoreLocation


class FineDustListViewModel{
    
    static var finedustList: [FineDust] = [FineDust(finedust: "-", finedustState: "-", finedustColor: .black, ultrafinedust: "-", ultrafinedustState: "-", ultrafinedustColor: .black, dateTime: "-", stationName: "-", currentLocation: "-",lat: 0, lng: 0, timeStamp: 0) ]


    lazy var finedustRelay = PublishRelay<[FineDust]>()
    
    let finedustViewModel = FineDustViewModel()

    func getFineDust(){
        var stationName: [String] = []
        
        FineDustListViewModel.finedustList.forEach{ i in
            stationName.append(i.stationName)
        }
        
        Observable.from(stationName)
            .flatMap{ station in APIService.loadFineDust(stationName: station)}
            .subscribe(onNext:{ [weak self] response in
                self?.setFinedustList(response)
            }, onCompleted: {
                print("completed")
                FineDustListViewModel.finedustList.sort{ $0.timeStamp > $1.timeStamp }
                self.finedustRelay.accept(FineDustListViewModel.finedustList)
            })

    }
    
    func reloadFineDustList(){
        finedustRelay.accept(FineDustListViewModel.finedustList)
    }
    
    func addCurrentLocationFineDust(_ finedust: FineDust){
        FineDustListViewModel.finedustList[0].finedust = finedust.finedust
        FineDustListViewModel.finedustList[0].finedustState = finedust.finedustState
        FineDustListViewModel.finedustList[0].finedustColor = finedust.finedustColor
        FineDustListViewModel.finedustList[0].ultrafinedust = finedust.ultrafinedust
        FineDustListViewModel.finedustList[0].ultrafinedustState = finedust.ultrafinedustState
        FineDustListViewModel.finedustList[0].ultrafinedustColor = finedust.ultrafinedustColor
        FineDustListViewModel.finedustList[0].dateTime = finedust.dateTime
        FineDustListViewModel.finedustList[0].stationName = finedust.stationName
        FineDustListViewModel.finedustList[0].lat = finedust.lat
        FineDustListViewModel.finedustList[0].lng = finedust.lng
        FineDustListViewModel.finedustList[0].timeStamp = finedust.timeStamp
    }
    
    func addCurrentLocationFineDust(_ currentLocation: String){
        FineDustListViewModel.finedustList[0].currentLocation = currentLocation
    }
    
    func addFineDust(_ finedust: FineDust){
        FineDustListViewModel.finedustList.append(finedust)
        saveFineDust()
    }
    
    func setFinedustList(_ apiFineDust: APIFineDust){
        
        for i in FineDustListViewModel.finedustList.indices{
            if FineDustListViewModel.finedustList[i].stationName == apiFineDust.stationName{
                FineDustListViewModel.finedustList[i] = self.finedustViewModel.finedust(value: apiFineDust, currentLocation: FineDustListViewModel.finedustList[i].currentLocation, lat: FineDustListViewModel.finedustList[i].lat, lng: FineDustListViewModel.finedustList[i].lng, timeStamp: FineDustListViewModel.finedustList[i].timeStamp)
                break
            }
        }
    }
    
    func removeFineDust(_ i: Int){
        FineDustListViewModel.finedustList.remove(at: i)
        saveFineDust()
        reloadFineDustList()
    }
    
    func saveFineDust(){
        var finedust: [StoreFineDust] = []

        for i in 1..<FineDustListViewModel.finedustList.count{
            finedust.append(StoreFineDust(stationName: FineDustListViewModel.finedustList[i].stationName, currentLocation: FineDustListViewModel.finedustList[i].currentLocation, lat: FineDustListViewModel.finedustList[i].lat, lng: FineDustListViewModel.finedustList[i].lng, timeStamp: FineDustListViewModel.finedustList[i].timeStamp))
        }
    
        Storage.store(finedust, to: .documents, as: "finedust.json")
    }
    
    func loadFineDust(){
        let storefinedust = Storage.retrive("finedust.json", from: .documents, as: [StoreFineDust].self) ?? []
        storefinedust.forEach{
            FineDustListViewModel.finedustList.append(FineDust(finedust: "-", finedustState: "-", finedustColor: .black, ultrafinedust: "-", ultrafinedustState: "-", ultrafinedustColor: .black, dateTime: "-", stationName: $0.stationName, currentLocation: $0.currentLocation, lat: $0.lat, lng: $0.lng, timeStamp: $0.timeStamp))
        }
    }
}
