//
//  APIError.swift
//  FineDust
//
//  Created by 홍승아 on 2021/08/29.
//

import Foundation

enum APIError: Error{
  case authError
  case tmAPIError
  case stationAPIError
  case finedustAPIError
}
