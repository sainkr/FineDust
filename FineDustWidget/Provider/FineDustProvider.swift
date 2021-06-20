//
//  FineDustProvider.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/20.
//

import WidgetKit
import SwiftUI
import Intents
import RxCocoa
import RxSwift

// TimelineProvider : Widget의 디스플레이를 업데이트 할 시기를 WidgetKit에 알려주는 타입
struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), finedust: FineDustRequest(location: "서울시 종로구", finedustValue: "30", finedustState: "보통", ultrafinedustValue: "10", ultrafinedustState: "좋음"),configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ())
    {
        let entry: SimpleEntry =  SimpleEntry(date: Date(), finedust: FineDustRequest(location: "서울시 종로구", finedustValue: "30", finedustState: "보통", ultrafinedustValue: "5", ultrafinedustState: "좋음") ,configuration: configuration)
        
        // context.isPreview{ // 추가 할 때 미리보기
        // context.family : widget 크기
        
        // context.environmentVariants.colorScheme
        
        completion(entry)
    }

    // 위젯 미리 업데이트 시키기
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        // 30분마다 refresh 하겠음
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
                
        /*GithubFetcher.getPulls(owner: "eunjin3786", repo: "MyRepo") { result in
            switch result {
            case .success(let pulls):
                let entry = Entry(date: currentDate, prList: pulls)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
            case .failure:
                let entry = Entry(prList: [PullRequest(url: "", state: "", title: "데이터를 가져올 수 없습니다.", user: User(name: "또르르", imageUrl: ""), createdDate: "로그인을 안한 것 아닐까요..?", updatedDate: "")])
                let entries: [Entry] = [entry]
                let timeline = Timeline(entries: entries, policy: .after(refreshDate))
                completion(timeline)
            }
        }*/
        
        /*APIService.loadFineDust(stationName: "중앙동(강원)")
            .take(1)
            .subscribe(onNext:{  value in
                print(value)
                let entry = SimpleEntry(date: currentDate, finedust: FineDustRequest(location: "원주시 태장동", finedustValue: value.finedust, finedustState: "보통", ultrafinedustValue: value.ultrafinedust, ultrafinedustState: "나쁨"), configuration: configuration)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
            })*/
        
        print("---> 진입 ?")
        APIService.loadFineDust(stationName: "중앙동(강원)")
            .take(1)
            .subscribe(onNext:{  value in
                print(value)
                let entry = SimpleEntry(date: currentDate, finedust: FineDustRequest(location: "원주시 태장동", finedustValue: value.finedust, finedustState: "보통", ultrafinedustValue: value.ultrafinedust, ultrafinedustState: "나쁨"), configuration: configuration)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            })
        
     
        /*var entries: [SimpleEntry] = []
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, finedust: FineDustRequest(location: "-", finedustValue: "-", finedustState: "-", ultrafinedustValue: "-", ultrafinedustState: "-"), configuration: configuration)
            entries.append(entry)
        }

        // atEnd : 타임라인의 마지막 날짜가 지난 후 WidgetKit이 새 타임라인을 요청하도록 지정하는 policy
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)*/
    }
}
