//
//  FineDustList.swift
//  FineDust
//
//  Created by νμΉμ on 2021/08/30.
//

import Foundation

class FineDustList{
  static let shared = FineDustList()
  var fineDustList: [FineDustData] = []
  var currentLocationFineDustAPIData: FineDustAPIData?
  var currentLocationLocationData: LocationData?
  var searchedFineDustAPIData: FineDustAPIData?
  var searchedLocationData: LocationData?
  private init(){}
}
