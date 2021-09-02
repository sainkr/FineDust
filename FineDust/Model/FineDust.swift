//
//  FineDust.swift
//  FineDust
//
//  Created by 홍승아 on 2021/05/31.
//

import UIKit

// MARK: - FineDustAPIData
struct FineDustAPIData{
  var dateTime: String
  var fineDust: FineDust
  var ultraFineDust: UltraFineDust
  var stationName: String
}

// MARK: - LocationData
struct LocationData: Codable{
  var locationName: String
  var latitude: Double
  var longtitude: Double
}

// MARK: - FineDustData
struct FineDustData{
  var timeStamp: Int
  var dateTime: String
  var fineDust: FineDust
  var ultraFineDust: UltraFineDust
  var stationName: String
  var location: LocationData
}

// MARK: - FineDust
struct FineDust{
  var fineDustValue: String
  var fineDustState: String
  var fineDustColor: UIColor
}

// MARK: - UltraFineDust
struct UltraFineDust{
  var ultraFineDustValue: String
  var ultraFineDustState: String
  var ultraFineDustColor: UIColor
}

// MARK: - StoredFineDustData
struct StoredFineDustData: Codable{
  var timeStamp: Int
  var stationName: String
  var location: LocationData
}
