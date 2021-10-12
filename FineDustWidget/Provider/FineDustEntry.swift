//
//  FineDustEntry.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/20.
//


import WidgetKit
import SwiftUI
import Intents

struct FineDustEntry: TimelineEntry {
  let date: Date // 필수적으로 요구 ..
  let finedust: FineDustRequest
}

struct FineDustRequest{
  let locationName: String
  let fineDust: FineDust
  let ultraFineDust: UltraFineDust
}

struct LocationInfo{
  var locationName: String
  var coordinate: CLLocationCoordinate2D
}
