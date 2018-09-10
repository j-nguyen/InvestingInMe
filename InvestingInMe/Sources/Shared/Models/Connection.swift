//
//  Connection.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-20.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxDataSources

public struct Connection: Decodable {
  public let id: Int
  public let inviter: User
  public let invitee: User
  public let accepted: Bool
  public let message: String
}
