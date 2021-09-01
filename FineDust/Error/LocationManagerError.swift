//
//  LocationManagerError.swift
//  FineDust
//
//  Created by 홍승아 on 2021/09/01.
//

import Foundation

enum LocationManagerError: Error {
  case authorizationDenied
  case coordinateError
}
