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
    
    static var finedustList: [FineDust] = [FineDust(finedust: "-", finedustState: "-", finedustColor: .black, ultrafinedust: "-", ultrafinedustState: "-", ultrafinedustColor: .black, dateTime: "-", stationName: "-",lat: 0, lng: 0) ]

    var apiFineDust: [APIFineDust] = []
    lazy var finedustRelay = PublishRelay<[FineDust]>()
    
    let finedustViewModel = FineDustViewModel()

    func getFineDust(){
        var stationName: [String] = [] // 일단 저장된거 불러와서
        
        FineDustListViewModel.finedustList.forEach{ i in
            stationName.append(i.stationName)
        }
        
        Observable.from(stationName)
            .flatMap{ station in APIService.loadFineDust(stationName: station)}
            .subscribe(onNext:{ [weak self] value in
                self?.apiFineDust.append(value)
            }, onCompleted: {
                for i in self.apiFineDust.indices{
                    let finedustList = FineDustListViewModel.finedustList[i]
                    let finedust = self.finedustViewModel.finedust(value: self.apiFineDust[i], lat: finedustList.lat, lng: finedustList.lng)
                    
                    FineDustListViewModel.finedustList[i] = finedust
                }
                
                self.finedustRelay.accept(FineDustListViewModel.finedustList)
            })

    }
    
    func addCurrentLocationFineDust(_ finedust: FineDust){
        FineDustListViewModel.finedustList[0] = finedust
    }
    
    func addFineDust(_ finedust: FineDust){
        FineDustListViewModel.finedustList.append(finedust)
    }

}
