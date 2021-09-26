//
//  FineDustProvider.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/20.
//

import CoreLocation
import WidgetKit
import SwiftUI
import Intents
import RxSwift

// TimelineProvider : Widget의 디스플레이를 업데이트 할 시기를 WidgetKit에 알려주는 타입
struct Provider: TimelineProvider {
  
  let fineDustViewModel = FineDustViewModel()
  let currentLocationViewModel = CurrentLocationViewModel()
  let locationManger = LocationManager()
  var currentLocation: CLLocationCoordinate2D?
  
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(),
                finedust: FineDustRequest(
                  locationName: "-",
                  fineDust: fineDustViewModel.fineDust("-"),
                  ultraFineDust: fineDustViewModel.ultraFineDust("-")))
  }
  
  // 위젯 갤러리의 미리보기인지 여부와 표시 할 위젯의 패밀리 또는 크기를 포함하여 항목 사용 방법에 대한 세부 정보가 포함 된 매개 변수를 제공합니다
  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry: SimpleEntry =  SimpleEntry(date: Date(),
                                          finedust:
                                            FineDustRequest(
                                              locationName: "서울시 종로구",
                                              fineDust: fineDustViewModel.fineDust("30"),
                                              ultraFineDust: fineDustViewModel.ultraFineDust("5")))
    completion(entry)
  }
  
  // 위젯 미리 업데이트 시키기
  func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    do {
      try locationManger.requestLocation(){ coordinate in
        currentLocationViewModel.convertToAddress(latitude: coordinate.latitude, longtitude: coordinate.longitude, completion: {
          let locationName = $0
          fineDustViewModel.loadFineDust(latitude: coordinate.latitude, longtitude: coordinate.longitude, completion: {
            let entry = simpleEntry(currentDate: currentDate,
                                    locationName: locationName,
                                    fineDust:  $0.fineDust,
                                    ultraFineDust: $0.ultraFineDust)
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
          })
        })
      }
    } catch {
      let entry = simpleEntry(currentDate: currentDate,
                              locationName: "위치 권한 오류",
                              fineDust: fineDustViewModel.fineDust("-"),
                              ultraFineDust: fineDustViewModel.ultraFineDust("-"))
      let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: currentDate)!
      let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
      completion(timeline)
    }
  }
  
  func simpleEntry(currentDate: Date, locationName: String, fineDust: FineDust, ultraFineDust: UltraFineDust)-> SimpleEntry{
    return SimpleEntry(
      date: currentDate,
      finedust: FineDustRequest(
        locationName: locationName,
        fineDust: fineDust,
        ultraFineDust: ultraFineDust))
  }
}
