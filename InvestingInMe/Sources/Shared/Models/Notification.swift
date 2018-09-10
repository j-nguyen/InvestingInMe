//
//  Notification.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-04-01.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct Notification: Decodable {
  public let user: User
  public let owner: User
  public let message: String
  public let type: String
  public let type_id: Int
  public let created_at: Date
  public let updated_at: Date
}
