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
    
    static var finedustList: [FineDustList] = [FineDustList(location: "-", stationName: "-", finedust: "-", finedustStatus: "-", ultrafinedust: "-", ultrafinedustState: "-")]

    var finedust: [FineDust] = []
    lazy var finedustRelay = BehaviorRelay<[FineDustList]>(value: [])
    
    let finedustViewModel = FineDustViewModel()

    func getFineDust(){
        var stationName: [String] = [] // 일단 저장된거 불러와서
        
        print("--------> finedustList : \(FineDustListViewModel.finedustList)")
        FineDustListViewModel.finedustList.forEach{ i in
            stationName.append(i.stationName)
        }
        
        Observable.from(stationName)
            .flatMap{ station in APIService.loadFineDust(stationName: station)}
            .subscribe(onNext:{ [weak self] value in
                self?.finedust.append(value)
            }, onCompleted: {
                for i in self.finedust.indices{
                    let finedustList = FineDustListViewModel.finedustList[i]
                    let finedust = FineDustList(location: finedustList.location, stationName: finedustList.stationName, finedust: self.finedust[i].finedust, finedustStatus: self.finedustViewModel.setFineDust(self.finedust[i].finedust), ultrafinedust: self.finedust[i].ultrafinedust, ultrafinedustState: self.finedustViewModel.setFineDust(self.finedust[i].ultrafinedust))
                    
                    FineDustListViewModel.finedustList[i] = finedust
                }
                print("----> finedustList : \(FineDustListViewModel.finedustList)")
                
                self.finedustRelay.accept(FineDustListViewModel.finedustList)
            }).dispose()
    }
    
    func addCurrentLocationFineDust(_ finedust: FineDust){
        /*
         var location: String
         var stationName: String
         var finedust: String
         var finedustStatus: String
         var ultrafinedust: String
         var ultrafinedustState: String
         */
        FineDustListViewModel.finedustList[0].finedust = finedust.finedust
        FineDustListViewModel.finedustList[0].finedustStatus = finedustViewModel.setFineDust(finedust.finedust)
        FineDustListViewModel.finedustList[0].ultrafinedust = finedust.ultrafinedust
        FineDustListViewModel.finedustList[0].ultrafinedustState = finedustViewModel.setUltraFineDust(finedust.ultrafinedust)
        FineDustListViewModel.finedustList[0].stationName = finedust.stationName
    }
    
    func addCurrentLocationFineDust(_ location: String){
        FineDustListViewModel.finedustList[0].location = location
    }
    
    func addFineDust(_ finedust: FineDust){
        /*
         var location: String
         var stationName: String
         var finedust: String
         var finedustStatus: String
         var ultrafinedust: String
         var ultrafinedustState: String
         */
        
        let i = FineDustListViewModel.finedustList.count - 1
        FineDustListViewModel.finedustList[i].finedust = finedust.finedust
        FineDustListViewModel.finedustList[i].finedustStatus = finedustViewModel.setFineDust(finedust.finedust)
        FineDustListViewModel.finedustList[i].ultrafinedust = finedust.ultrafinedust
        FineDustListViewModel.finedustList[i].ultrafinedustState = finedustViewModel.setUltraFineDust(finedust.ultrafinedust)
        FineDustListViewModel.finedustList[i].stationName = finedust.stationName
    }
    
    func addFineDust(_ location: String){
        let i = FineDustListViewModel.finedustList.count - 1
        FineDustListViewModel.finedustList[i].location = location
    }
}
