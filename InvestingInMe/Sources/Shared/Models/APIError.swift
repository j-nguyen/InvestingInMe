//
//  APIError.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-17.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct APIError: Decodable {
  public let reason: String
  public let error: Bool
  
  public init(reason: String, error: Bool) {
    self.reason = reason
    self.error = error
  }
}
