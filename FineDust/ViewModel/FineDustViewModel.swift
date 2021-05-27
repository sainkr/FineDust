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

struct TM{
    var tmX: Double
    var tmY: Double
}

class FineDustViewModel{

    func getFineDust(lat: Double, lng: Double){
        loadTM(lat: lat, lng: lng)
            .map{ tm in
                self.loadStation(tmX: tm.tmX, tmY: tm.tmY)
                    .map{ station in
                        self.loadFineDust(stationName: station)
                            .map{ finedust in
                                return finedust
                            }
                    }
            }
            .subscribe(onNext: { finedust in
                print("-----> findust : \(finedust)")
            })
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
        let accessToken = "83ccf4a2-16e6-4904-bc05-75ff40a1dc79"
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
    
    func loadFineDust(stationName: String) -> Observable<String>{
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
    
    func fetchFineDust(stationName: String, onComplete: @escaping (Result<String, Error>) -> Void){
        var url = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
        url += "?stationName="
        url += stationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        url += "&dataTerm=daily"
        url += "&pageNo=1"
        url += "&numOfRows=100"
        url += "&returnType=json"
        url += "&serviceKey="+servicekey
        
        AF.request(url, method: .get, encoding: URLEncoding.default)
            .responseJSON{ (response) in
                switch response.result{
                case let .success(data):
                    let json = JSON(data)
                    let finedust: String = json["response"]["body"]["items"][0]["pm10Value"].string!
                    print("---> 미세먼지 : \(finedust)")
                    onComplete(.success(finedust))
                case let .failure(error):
                    print(error)
                    onComplete(.failure(error))
                }
            }
    }
    
    /*func fetchFineDust(onComplete: @escaping (Result<String, Error>) -> Void){
        URLSession.shared.dataTask(with: URL(string: url)!) { data, res, err in
            if let err = err {
                onComplete(.failure(err))
                return
            }
            guard let data = data else {
                return
            }

            var responses = [String: Any]()
            var bodys = [String: Any]()
            var items = [[String : Any]]()

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else{
                return
            }

            responses = json["response"] as! [String : Any]
            bodys = responses["body"] as! [String : Any]
            items = bodys["items"] as! [[String : Any]]
            let item: [String : Any] = items[0]
            let finedust: String = item["pm10Value"] as! String
        
            onComplete(.success(finedust))
            
        }.resume()
    }*/
}
