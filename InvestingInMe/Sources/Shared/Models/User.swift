//
//  User.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct User: Decodable {
  public let id: Int
  public let google_id: String
  public let email: String
  public let name: String
  public let picture: URL
  public let email_verification: Bool
  public let description: String
  public let role: Role?
  public let location: String
  public let phone_number: String
  public let experience_and_credentials: String
  public let player_id: String?
}

extension User: Equatable {
  public static func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
  }
}
