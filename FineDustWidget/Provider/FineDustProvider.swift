//
//  FineDustProvider.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/20.
//

import WidgetKit
import SwiftUI
import Intents
import RxSwift

// TimelineProvider : Widget의 디스플레이를 업데이트 할 시기를 WidgetKit에 알려주는 타입
struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), finedust: FineDustRequest(location: "-", finedustValue: "-", finedustState: "-", finedustColor: .black, ultrafinedustValue: "-", ultrafinedustState: "-", ultrafinedustColor: .black),configuration: ConfigurationIntent())
    }

    // 위젯 갤러리의 미리보기인지 여부와 표시 할 위젯의 패밀리 또는 크기를 포함하여 항목 사용 방법에 대한 세부 정보가 포함 된 매개 변수를 제공합니다
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ())
    {
        let entry: SimpleEntry =  SimpleEntry(date: Date(), finedust: FineDustRequest(location: "서울시 종로구", finedustValue: "30", finedustState: "보통", finedustColor: #colorLiteral(red: 0.08792158216, green: 0.7761771083, blue: 0.2295451164, alpha: 1), ultrafinedustValue: "13", ultrafinedustState: "좋음", ultrafinedustColor: #colorLiteral(red: 0.1309628189, green: 0.6049023867, blue: 1, alpha: 1)) ,configuration: configuration)

        completion(entry)
    }

    // 위젯 미리 업데이트 시키기
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
    
        let finedustViewModel = FineDustViewModel()
        
        finedustViewModel.getFineDust(completion: {
            let entry = SimpleEntry(date: currentDate, finedust: FineDustRequest(location: "원주시 태장동", finedustValue: $0.finedustValue, finedustState: $0.finedustState, finedustColor: $0.finedustColor, ultrafinedustValue: $0.ultrafinedustValue, ultrafinedustState: $0.ultrafinedustState, ultrafinedustColor: $0.ultrafinedustColor), configuration: configuration)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        })
        
        // atEnd : 타임라인의 마지막 날짜가 지난 후 WidgetKit이 새 타임라인을 요청하도록 지정하는 policy
    }
}
