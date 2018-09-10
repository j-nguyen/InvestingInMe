//
//  CreateProject.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-18.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

/// We'll use this as a basis to create our parameters
public struct CreateProject: Codable {
  public let user_id: Int
  public let name: String
  public let category_id: Int
  public let role_id: Int
  public let project_description: String
  public let description_needs: String
  
  public init(
    user_id: Int,
    name: String,
    category_id: Int,
    role_id: Int,
    project_description: String,
    description_needs: String
  ) {
    self.user_id = user_id
    self.name = name
    self.category_id = category_id
    self.role_id = role_id
    self.project_description = project_description
    self.description_needs = description_needs
  }
}
