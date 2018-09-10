//
//  UpdateProject.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-04-01.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

/// We'll use this as a basis to create our parameters
public struct UpdateProject: Codable {
  public let name: String
  public let category_id: Int
  public let role_id: Int
  public let project_description: String
  public let description_needs: String
  
  public init(
    name: String,
    category_id: Int,
    role_id: Int,
    project_description: String,
    description_needs: String
  ) {
    self.name = name
    self.category_id = category_id
    self.role_id = role_id
    self.project_description = project_description
    self.description_needs = description_needs
  }
}

