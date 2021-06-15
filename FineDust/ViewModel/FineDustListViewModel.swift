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
    
    static var finedustList: [FineDust] = [FineDust(finedust: "-", finedustState: "-", finedustColor: .black, ultrafinedust: "-", ultrafinedustState: "-", ultrafinedustColor: .black, dateTime: "-", stationName: "-",lat: 0, lng: 0, timeStamp: 0) ]


    lazy var finedustRelay = PublishRelay<[FineDust]>()
    
    let finedustViewModel = FineDustViewModel()

    func getFineDust(){
        var stationName: [String] = [] // 일단 저장된거 불러와서
        var apiFineDust: [APIFineDust] = []
        
        FineDustListViewModel.finedustList.forEach{ i in
            stationName.append(i.stationName)
        }
        
        Observable.from(stationName)
            .flatMap{ station in APIService.loadFineDust(stationName: station)}
            .subscribe(onNext:{
                apiFineDust.append($0)
            }, onCompleted: {
                for i in FineDustListViewModel.finedustList.indices{
                    let finedustList = FineDustListViewModel.finedustList[i]
                    //print("----- > fine")
                    //print(finedustList)
                    print("finedust : \(finedustList.stationName) , timestamp : \(finedustList.timeStamp)")
                    let finedust = self.finedustViewModel.finedust(value: apiFineDust[i], lat: finedustList.lat, lng: finedustList.lng, timeStamp: finedustList.timeStamp)
                    
                    FineDustListViewModel.finedustList[i] = finedust
                }
                
                FineDustListViewModel.finedustList.sort{ $0.timeStamp > $1.timeStamp }
                // print("finedustLsit")
                // print(FineDustListViewModel.finedustList)
                self.finedustRelay.accept(FineDustListViewModel.finedustList)
            })

    }
    
    func addCurrentLocationFineDust(_ finedust: FineDust){
        FineDustListViewModel.finedustList[0] = finedust
    }
    
    func addFineDust(_ finedust: FineDust){
        FineDustListViewModel.finedustList.append(finedust)
        getFineDust()
    }

}
