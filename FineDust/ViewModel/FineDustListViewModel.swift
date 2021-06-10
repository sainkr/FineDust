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
        let stationName = ["중앙동(강원)","종로구"] // 일단 저장된거 불러와서
        
        Observable.from(stationName)
            .flatMap{ station in APIService.loadFineDust(stationName: station)}
            .subscribe(onNext:{ [weak self] value in
                self?.finedust.append(value)
            }, onCompleted: {
                
                self.finedust.forEach{ value in
                    // finedustList.append()
                }
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
