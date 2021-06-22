//
//  API.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/10.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON


private let servicekey = "ic1bRMghX2rxMK8sUa%2B2cyNOyPqz96fTfOIbi1fHykBtmAg4D2B46M2fsdC8z7B%2ByeS0xeIsXdmiKqIrUFdevA%3D%3D"
private let accessToken = "9dc1452f-e158-44bf-addb-2922541945e2"

class APIService{
    static func loadTM(lat: Double, lng: Double) -> Observable<TM>{
        return Observable.create{ emitter in
            self.fetchTM(posX: lng, posY: lat){ result in
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
    
    static func fetchTM(posX: Double, posY: Double, onComplete: @escaping (Result<TM, Error>) -> Void){
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
    
    static func loadStation(tmX: Double, tmY: Double) -> Observable<String>{
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
    
    static func fetchStation(tmX: Double, tmY: Double, onComplete: @escaping (Result<String, Error>) -> Void){
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
                    print(json)
                    let station: String = json["response"]["body"]["items"][0]["stationName"].string!
                    onComplete(.success(station))
                case .failure(let error):
                    print(" ---> error : station")
                    onComplete(.failure(error))
                }
            }
    }
    
    static func loadFineDust(stationName: String) -> Observable<APIFineDust>{
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
    
    static func fetchFineDust(stationName: String, onComplete: @escaping (Result<APIFineDust, Error>) -> Void){
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
                    
                    let finedust: String = json["response"]["body"]["items"][0]["pm10Value"].string!
                    let ultrafinedust: String = json["response"]["body"]["items"][0]["pm25Value"].string!
                    let dateTime: String = json["response"]["body"]["items"][0]["dataTime"].string!
                    
                    let response = APIFineDust(finedust: finedust, ultrafinedust: ultrafinedust, dateTime: dateTime, stationName: stationName)
                    
                    onComplete(.success(response))
                case let .failure(error):
                    print("----> error : 측정소 실시간")
                    onComplete(.failure(error))
                }
            }
    }
}

