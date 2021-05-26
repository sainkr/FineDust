//
//  ViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/05/25.
//

import UIKit
import RxSwift
import RxCocoa

var url = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"

class ViewController: UIViewController {
    
    
    let disposeBag = DisposeBag()
    let region = "중앙동(강원)"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        url += "?stationName="
        url += region.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        url += "&dataTerm=daily"
        url += "&pageNo=1"
        url += "&numOfRows=100"
        url += "&returnType=json"
        url += "&serviceKey="+servicekey
        
        loadFineDust()
            .subscribe(onNext: { response in
                print(response)
            }, onError: { err in
                print(err)
            }, onCompleted: {
                
            }, onDisposed: {
                
            }).disposed(by: disposeBag)
    }
    
    // https://zeddios.tistory.com/156
    
    // {"response":{"body":{"totalCount":23,"items":[{"so2Grade":"1","coFlag":null,"khaiValue":"69","so2Value":"0.005","coValue":"0.4","pm25Flag":null,"pm10Flag":null,"pm10Value":"43","o3Grade":"2","khaiGrade":"2","pm25Value":"16","no2Flag":null,"no2Grade":"1","o3Flag":null,"pm25Grade":"2","so2Flag":null,"dataTime":"2021-05-26 20:00","coGrade":"1","no2Value":"0.016","pm10Grade":"2","o3Value":"0.053"},{"so2Grade":"1","coFlag":null,"khaiValue":"69","so2Value":"0.003","coValue":"0.4","pm25Flag":null,"pm10Flag":null,"pm10Value":"48","o3Grade":"2","khaiGrade":"2","pm25Value":"20","no2Flag":null,"no2Grade":"1","o3Flag":null,"pm25Grade":"2","so2Flag":null,"dataTime":"2021-05-26 19:00","coGrade":"1","no2Value":"0.018","pm10Grade":"2","o3Value":"0.053"},{"so2Grade":"1","coFlag":null,"khaiValue":"73","so2Value":"0.004","coValue":"0.4","pm25Flag":null,"pm10Flag":null,"pm10Value":"51","o3Grade":"2","khaiGrade":"2","pm25Value":"18","no2Flag":null,"no2Grade":"1","o3Flag":null,"pm25Grade":"1","so2Flag":null,"dataTime":"2021-05-26 18:00","coGrade":"1","no2Value":"0.016","pm10Grade":"2","o3Value":"0.058"},{"so2Grade":"1","coFlag":null,"khaiValue":"73","so2Value":"0.004","coValue":"0.4","pm25Flag":null,"pm10Flag":null,"pm10Value":"52","o3Grade":"2","khaiGrade":"2","pm25Value":"17","no2Flag":null,"no2Grade":"1","o3Flag":null,"pm25Grade":"1","so2Flag":null,"dataTime":"2021-05-26 17:00","coGrade":"1","no2Value":"0.013","pm10Grade":"2","o3Value":"0.058"},{"so2Grade":"1","coFlag":null,"khaiValue":"72","so2Value":"0.004","coValue":"0.4","pm25Flag":null,"pm10Flag":null,"pm10Value":"50","o3Grade":"2","khaiGrade":"2","pm25Value":"13","no2Flag":nu
    
    func loadFineDust() -> Observable<String>{
        return Observable.create{ emitter in
            
            URLSession.shared.dataTask(with: URL(string: url)!) { data, res, err in
                if let err = err {
                    emitter.onError(err)
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
                
                print(finedust)
                emitter.onNext(finedust)
                emitter.onCompleted()
                
            }.resume()
            
            emitter.onCompleted()
            
            
            return Disposables.create()
        }
    }
}
