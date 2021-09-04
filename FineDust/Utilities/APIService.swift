//
//  API.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/10.
//

import Foundation

import Alamofire
import RxSwift
import SwiftyJSON

class APIService{
  
  static func loadTM(latitude: Double, longtitude: Double) -> Observable<TM>{
    return Observable.create{ emitter in
      self.fetchTM(posX: longtitude, posY: latitude){ result in
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
    let url = FineDustAPI.tmURL
    let param = tmParameter(posX: posX, posY: posY)
    
    AF.request(url, method: .get, parameters: param, encoding: URLEncoding.default)
      .responseJSON{ (response) in
        switch response.result{
        case .success(let data):
          let json = JSON(data)
          guard json["errMsg"] == "Success" else {
            print("tm Error")
            onComplete(.failure(APIError.tmAPIError))
            return
          }
          guard let tmX = json["result"]["posX"].double else {
            print("tmX Error")
            onComplete(.failure(APIError.tmAPIError))
            return
          }
          guard let tmY = json["result"]["posY"].double else {
            print("tmY Error")
            onComplete(.failure(APIError.tmAPIError))
            return
          }
          // print(tmX, tmY)
          onComplete(.success(TM(tmX: tmX, tmY: tmY)))
          
        case .failure(let error):
          print(" ---> error : \(APIError.tmAPIError)")
          onComplete(.failure(error))
        }
      }
  }
  
  static func tmParameter(posX: Double, posY: Double)-> Parameters{
    return [
      "accessToken" : FineDustAPI.accessToken,
      "src" : "4326",
      "dst" : "5181",
      "posX" : posX ,
      "posY" : posY
    ]
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
    let url = stationURL(tmX: tmX, tmY: tmY)

    AF.request(url, method: .get, encoding: URLEncoding.default)
      .responseJSON{ (response) in
        switch response.result{
        case .success(let data):
          let json = JSON(data)
          guard let station: String = json["response"]["body"]["items"][0]["stationName"].string else {
            onComplete(.failure(APIError.stationAPIError))
            return
          }
          // print(station)
          onComplete(.success(station))
        case .failure(let error):
          print(" ---> error : \(APIError.stationAPIError)")
          onComplete(.failure(error))
        }
      }
    
    /*var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let err = error {
        print(" ---> error : \(APIError.stationAPIError)")
        onComplete(.failure(err))
      }
      guard let data = data else {
        onComplete(.failure(APIError.stationAPIError))
        return
      }
      let json = JSON(data)
      guard let station: String = json["response"]["body"]["items"][0]["stationName"].string else {
        onComplete(.failure(APIError.stationAPIError))
        return
      }
      onComplete(.success(station))
    }.resume()*/
  }
  
  static func stationURL(tmX: Double, tmY: Double)-> String{
    var url = FineDustAPI.stationURL
    url += "?tmX=\(tmX)"
    url += "&tmY=\(tmY)"
    url += "&returnType=json"
    url += "&serviceKey=\(FineDustAPI.servicekey)"
    return url
  }
  
  
  static func loadFineDust(stationName: String) -> Observable<FineDustAPIData>{
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
  
  static func fetchFineDust(stationName: String, onComplete: @escaping (Result<FineDustAPIData, Error>) -> Void){
    let url = fineDustURL(stationName: stationName)
    
    AF.request(url, method: .get, encoding: URLEncoding.default)
      .responseJSON{ (response) in
        switch response.result{
        case let .success(data):
          let json = JSON(data)
          guard let fineDustValue: String = json["response"]["body"]["items"][0]["pm10Value"].string else {
            print("finedust Error")
            onComplete(.failure(APIError.finedustAPIError))
            return
          }
          guard let ultraFineDustValue: String = json["response"]["body"]["items"][0]["pm25Value"].string else {
            print("ultrafinedust Error")
            onComplete(.failure(APIError.finedustAPIError))
            return
          }
          guard let dateTime: String = json["response"]["body"]["items"][0]["dataTime"].string else {
            print("dateTime Error")
            onComplete(.failure(APIError.finedustAPIError))
            return
          }
          
          let fineDustViewModel = FineDustViewModel()
          let fineDust = fineDustViewModel.fineDust(fineDustValue)
          let ultraFineDust = fineDustViewModel.ultraFineDust(ultraFineDustValue)
          
          let response = FineDustAPIData(dateTime: dateTime, fineDust: fineDust, ultraFineDust: ultraFineDust, stationName: stationName)
          
          // print(response)
          onComplete(.success(response))
        case let .failure(error):
          onComplete(.failure(error))
        }
      }
  }
  
  static func fineDustURL(stationName: String)-> String{
    var url = FineDustAPI.finedustURL
    url += "?stationName="
    url += stationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    url += "&dataTerm=daily"
    url += "&pageNo=1"
    url += "&numOfRows=100"
    url += "&returnType=json"
    url += "&ver=1.3"
    url += "&serviceKey=\(FineDustAPI.servicekey)"
    return url
  }
}
