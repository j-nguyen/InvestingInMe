//
//  Project.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct Project: Decodable {
  public let id: Int
  public let user: User
  public let name: String
  public let category: Category
  public let role: Role
  public let project_description: String
  public let description_needs: String
  public let assets: [Asset]
}
