//
//  RouteError.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-16.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public enum RouteError: Error {
  case invalidRoute(String)
  case invalidParameters(String)
}
