//
//  FineDustAPI.swift
//  FineDust
//
//  Created by νμΉμ on 2021/08/25.W
//

import Foundation

class FineDustAPI{
  static let authURL = "https://sgisapi.kostat.go.kr/OpenAPI3/auth/authentication.json"
  static let tmURL = "https://sgisapi.kostat.go.kr/OpenAPI3/transformation/transcoord.json"
  static let stationURL = "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList"
  static let finedustURL = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
  static let servicekey = "ic1bRMghX2rxMK8sUa%2B2cyNOyPqz96fTfOIbi1fHykBtmAg4D2B46M2fsdC8z7B%2ByeS0xeIsXdmiKqIrUFdevA%3D%3D"
  static let serviceID = "7bc16e2fe86d4d46839d"
  static let secretKey = "17f8a161b2524750b1ca"
}
