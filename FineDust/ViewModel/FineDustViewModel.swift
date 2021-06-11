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
    
    lazy var observable = PublishRelay<FineDust>()
    
    func getFineDust(lat: Double, lng: Double){
       _ = APIService.loadTM(lat: lat, lng: lng)
            .flatMap{ tm in APIService.loadStation(tmX: tm.tmX, tmY: tm.tmY)}
            .flatMap{ station in APIService.loadFineDust(stationName: station)}
            .take(1)
            .bind(to: observable)
    }
    
    func setFineDustColor(_ result: String) -> UIColor{
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
    
    func setFineDust(_ result: String) -> String{
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
    
    func setUltraFineDustColor(_ result: String) -> UIColor{
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
    
    func setUltraFineDust(_ result: String) -> String{
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
    func calculatorFineDust(_ value: Int) -> Float{
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
    func calculatorUltraFineDust(_ value: Int) -> Float{
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

