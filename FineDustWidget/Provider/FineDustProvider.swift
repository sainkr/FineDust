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
  
  func placeholder(in context: Context) -> FineDustEntry {
    let fineDustViewModel = FineDustViewModel()
    return FineDustEntry(date: Date(),
                finedust: FineDustRequest(
                  locationName: "-",
                  fineDust: fineDustViewModel.fineDust("-"),
                  ultraFineDust: fineDustViewModel.ultraFineDust("-")))
  }
  
  // 위젯 갤러리의 미리보기인지 여부와 표시 할 위젯의 패밀리 또는 크기를 포함하여 항목 사용 방법에 대한 세부 정보가 포함 된 매개 변수를 제공합니다
  func getSnapshot(in context: Context, completion: @escaping (FineDustEntry) -> Void) {
    let fineDustViewModel = FineDustViewModel()
    let entry: FineDustEntry =  FineDustEntry(date: Date(),
                                          finedust:
                                            FineDustRequest(
                                              locationName: "서울시 종로구",
                                              fineDust: fineDustViewModel.fineDust("30"),
                                              ultraFineDust: fineDustViewModel.ultraFineDust("5")))
    completion(entry)
  }
  
  // 위젯 미리 업데이트 시키기
  func getTimeline(in context: Context, completion: @escaping (Timeline<FineDustEntry>) -> Void) {
    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let fineDustViewModel = FineDustViewModel()
    fetchFineDustAPIData{ result in
      switch result{
      case .success(let entry):
        let refreshDate = refreshDate(entry.date)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
      case .failure(_):
        let entry = fineDustEntry(currentDate: Date(),
                                locationName: "위치 권한 오류",
                                fineDust: fineDustViewModel.fineDust("-"),
                                ultraFineDust: fineDustViewModel.ultraFineDust("-"))
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to:  Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
      }
    }
  }
  
  private func fineDustEntry(currentDate: Date, locationName: String, fineDust: FineDust, ultraFineDust: UltraFineDust)-> FineDustEntry{
    return FineDustEntry(
      date: currentDate,
      finedust: FineDustRequest(
        locationName: locationName,
        fineDust: fineDust,
        ultraFineDust: ultraFineDust))
  }
  
  private func refreshDate(_ currentDate: Date)-> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "mm"
    let currentMinute = Int(formatter.string(from: Date())) ?? 0
    return Calendar.current.date(byAdding: .minute, value: 63 - currentMinute, to: currentDate)!
  }
  
  private func fetchFineDustAPIData(onComplete: @escaping (Result<FineDustEntry, Error>) -> Void){
    let fineDustViewModel = FineDustViewModel()
    fetchLocation(){ result in
      switch result {
      case .success(let locationInfo):
        fineDustViewModel.loadFineDust(coordinate: locationInfo.coordinate){
          let currentDate = Date()
          let entry = fineDustEntry(currentDate: currentDate,
                                  locationName: locationInfo.locationName,
                                  fineDust: $0.fineDust,
                                  ultraFineDust: $0.ultraFineDust)
          onComplete(.success(entry))
        }
      case .failure(let error):
        onComplete(.failure(error))
      }
    }
  }
  
  private func fetchLocation(onComplete: @escaping (Result<LocationInfo, Error>) -> Void){
    let locationManger = LocationManager()
    let currentLocationViewModel = CurrentLocationViewModel()
    do {
      try locationManger.requestLocation(){ coordinate in
        currentLocationViewModel.convertToAddress(latitude: coordinate.latitude, longtitude: coordinate.longitude){ locationName in
          let locationInfo = LocationInfo(locationName: locationName, coordinate: coordinate)
          onComplete(.success(locationInfo))
        }
      }
    }
   catch {
      onComplete(.failure(LocationManagerError.coordinateError))
   }
  }
}
