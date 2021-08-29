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
  let fineDustViewModel = FineDustViewModel()
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(),
                finedust: FineDustRequest(
                  locationName: "-",
                  fineDust: fineDustViewModel.fineDust("-"),
                  ultraFineDust: fineDustViewModel.ultraFineDust("-")),
                configuration: ConfigurationIntent())
  }
  
  // 위젯 갤러리의 미리보기인지 여부와 표시 할 위젯의 패밀리 또는 크기를 포함하여 항목 사용 방법에 대한 세부 정보가 포함 된 매개 변수를 제공합니다
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ())
  {
    let entry: SimpleEntry =  SimpleEntry(date: Date(),
                                          finedust:
                                            FineDustRequest(
                                              locationName: "서울시 종로구",
                                              fineDust: fineDustViewModel.fineDust("30"),
                                              ultraFineDust: fineDustViewModel.ultraFineDust("5")),
                                              configuration: configuration)
    completion(entry)
  }
  
  
  // 위젯 미리 업데이트 시키기
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
    
    let defaults = UserDefaults(suiteName: "group.com.sainkr.FineDust")
    
    guard let stationName = defaults?.string(forKey: "stationName"), let locationName = defaults?.string(forKey: "locationName") else {
      let entry = SimpleEntry(
        date: Date(),
        finedust:FineDustRequest(
          locationName: "오류",
          fineDust: fineDustViewModel.fineDust("-") ,
          ultraFineDust: fineDustViewModel.ultraFineDust("-")),
        configuration: configuration)
      let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
      completion(timeline)
      return }
    
    fineDustViewModel.loadFineDust(station: stationName, completion: {
      let entry = SimpleEntry(
        date: currentDate,
        finedust: FineDustRequest(
          locationName: locationName,
          fineDust: $0.fineDust,
          ultraFineDust: $0.ultraFineDust),
        configuration: configuration)
      let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
      completion(timeline)
    })
  }
}
