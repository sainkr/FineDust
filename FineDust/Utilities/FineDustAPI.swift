//
//  FineDustAPI.swift
//  FineDust
//
//  Created by 홍승아 on 2021/08/25.W
//

import Foundation

class FineDustAPI{
  static let authURL = "https://sgisapi.kostat.go.kr/OpenAPI3/auth/authentication.json"
  static let tmURL = "https://sgisapi.kostat.go.kr/OpenAPI3/transformation/transcoord.json"
  static let stationURL = "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList"
  static let finedustURL = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
}
