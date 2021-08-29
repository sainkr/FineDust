//
//  FineDust.swift
//  FineDust
//
//  Created by 홍승아 on 2021/05/31.
//

import UIKit

struct FineDust{
  var fineDustValue: String
  var fineDustState: String
  var fineDustColor: UIColor
}

struct UltraFineDust{
  var ultraFineDustValue: String
  var ultraFineDustState: String
  var ultraFineDustColor: UIColor
}

struct StoredFineDustData: Codable{
  var timeStamp: Int
  var stationName: String
  var location: LocationData
}

// api
// dateTime, fineDusdtValue, ultraFineDustValue, stationName
struct FineDustAPIData{
  var dateTime: String
  var fineDust: FineDust
  var ultraFineDust: UltraFineDust
  var stationName: String
}

// location
// lat, lng, locationName
struct LocationData: Codable{
  var locationName: String
  var latitude: Double
  var longtitude: Double
}

// finedustData

// 두 개ㅡㄹㄹ 합한..
struct FineDustData{
  var timeStamp: Int
  var dateTime: String
  var fineDust: FineDust
  var ultraFineDust: UltraFineDust
  var stationName: String
  var location: LocationData
}
