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

let servicekey = "ic1bRMghX2rxMK8sUa%2B2cyNOyPqz96fTfOIbi1fHykBtmAg4D2B46M2fsdC8z7B%2ByeS0xeIsXdmiKqIrUFdevA%3D%3D"
let accessToken = "20d16308-c5a4-4339-a6f4-40644f4a30bb"

class FineDustViewModel{
    var currentFineDust = FineDust(finedust: "-", ultrafinedust: "-", stationName: "-", dateTime: "-")
    
    lazy var observable = PublishRelay<FineDust>()
    lazy var finedustRelay = BehaviorRelay<[FineDust]>(value: [])

    func getFineDust(lat: Double, lng: Double){
        _ = loadTM(lat: lat, lng: lng)
            .flatMap{ tm in self.loadStation(tmX: tm.tmX, tmY: tm.tmY)}
            .flatMap{ station in self.loadFineDust(stationName: station)}
            .take(1)
            .bind(to: observable)
    }
    
    func loadTM(lat: Double, lng: Double) -> Observable<TM>{
        return Observable.create{ emitter in
            self.fetchTM(posX: lat, posY: lng){ result in
                switch result {
                case let .success(tm):
                    emitter.onNext(tm)
                    emitter.onCompleted()
                case let .failure(error):
                    emitter.onError(error)
                }
                
            }
            return Disposables.create()
        }
    }

    func fetchTM(posX: Double, posY: Double, onComplete: @escaping (Result<TM, Error>) -> Void){
        let url = "https://sgisapi.kostat.go.kr/OpenAPI3/transformation/transcoord.json"
        let param: Parameters = [
            "accessToken" : accessToken,
            "src" : "4326",
            "dst" : "5181",
            "posX" : posX ,
            "posY" : posY
        ]
        
        AF.request(url, method: .get, parameters: param,encoding: URLEncoding.default)
            .responseJSON{ (response) in
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    print(json)
                    guard json["errMsg"] == "Success" else {
                        onComplete(.failure(NSError(domain: "TM Parsing Error", code: 1, userInfo: nil)))
                        return
                    }
                    
                    let tmX = json["result"]["posX"].double!
                    let tmY = json["result"]["posY"].double!
                    onComplete(.success(TM(tmX: tmX, tmY: tmY)))
                    
                case .failure(let error):
                    print(" ---> error : \(error)")
                    onComplete(.failure(error))
                }
            }
    }
    
    func loadStation(tmX: Double, tmY: Double) -> Observable<String>{
        return Observable.create{ emitter in
            self.fetchStation(tmX: tmX, tmY: tmY){ result in
                switch result {
                case let .success(finedust):
                    emitter.onNext(finedust)
                    emitter.onCompleted()
                case let .failure(error):
                    emitter.onError(error)
                }
                
            }
            return Disposables.create()
        }
    }
    
    func fetchStation(tmX: Double, tmY: Double, onComplete: @escaping (Result<String, Error>) -> Void){
        var url = "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList"
        url += "?tmX=\(tmX)"
        url += "&tmY=\(tmY)"
        url += "&returnType=json"
        url += "&serviceKey=\(servicekey)"
        
        AF.request(url, method: .get, encoding: URLEncoding.default)
            .responseJSON{ (response) in
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    let station: String = json["response"]["body"]["items"][0]["stationName"].string!
                    onComplete(.success(station))
                case .failure(let error):
                    print(" ---> error : \(error)")
                    onComplete(.failure(error))
                }
            }
    }
    
    func loadFineDust(stationName: String) -> Observable<FineDust>{
        return Observable.create{ emitter in
            self.fetchFineDust(stationName: stationName){ result in
                switch result {
                case let .success(finedust):
                    emitter.onNext(finedust)
                    emitter.onCompleted()
                case let .failure(error):
                    emitter.onError(error)
                }
                
            }
            return Disposables.create()
        }
    }
    
    func fetchFineDust(stationName: String, onComplete: @escaping (Result<FineDust, Error>) -> Void){
        var url = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
        url += "?stationName="
        url += stationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        url += "&dataTerm=daily"
        url += "&pageNo=1"
        url += "&numOfRows=100"
        url += "&returnType=json"
        url += "&ver=1.3"
        url += "&serviceKey="+servicekey
        
        AF.request(url, method: .get, encoding: URLEncoding.default)
            .responseJSON{ (response) in
                switch response.result{
                case let .success(data):
                    let json = JSON(data)
                    print(json["response"]["body"]["items"])
                    let finedust: String = json["response"]["body"]["items"][0]["pm10Value"].string!
                    let ultrafinedust: String = json["response"]["body"]["items"][0]["pm25Value"].string!
                    let dateTime: String = json["response"]["body"]["items"][0]["dataTime"].string!
                    let response = FineDust(finedust: finedust, ultrafinedust: ultrafinedust, stationName: stationName, dateTime: dateTime)
                    self.currentFineDust = response
                    onComplete(.success(response))
                case let .failure(error):
                    print(error)
                    onComplete(.failure(error))
                }
            }
    }
    
    func setFineDustColor(_ result: String) -> UIColor{
        guard let value = Int(result) else {
            return .black
        }
        if value <= 30 {
            return .green
        }else if value <= 80 {
            return .blue
        }else if value <= 150 {
            return .red
        }else {
            return .red
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
            return .green
        }else if value <= 35 {
            return .blue
        }else if value <= 70 {
            return .red
        }else {
            return .red
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
