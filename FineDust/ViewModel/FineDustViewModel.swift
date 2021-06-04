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
let accessToken = "e10de305-74c6-4f9e-946f-d6926e50a912"

class FineDustViewModel{
    
    lazy var observable = PublishRelay<FineDust>()
    
    func getFineDust(lat: Double, lng: Double){
        _ = loadTM(lat: lat, lng: lng)
            .flatMap{ tm in self.loadStation(tmX: tm.tmX, tmY: tm.tmY)}
            .flatMap{ station in self.loadFineDust(stationName: station)}
            .take(1)
            .bind(to: observable)
            /*.subscribe(onNext: {
                self.observable.accept($0)
            })*/
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
                    // print(json["response"]["body"]["items"][0])
                    let finedust: String = json["response"]["body"]["items"][0]["pm10Value"].string!
                    let ultrafinedust: String = json["response"]["body"]["items"][0]["pm25Value"].string!
                    let response = FineDust(finedust: finedust, ultrafinedust: ultrafinedust)
                    onComplete(.success(response))
                case let .failure(error):
                    print(error)
                    onComplete(.failure(error))
                }
            }
    }
}
