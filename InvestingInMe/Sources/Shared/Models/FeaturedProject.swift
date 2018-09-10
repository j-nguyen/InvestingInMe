//
//  FeaturedProject.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct FeaturedProject: Decodable {
  public let id: Int
  public let project: Project
  public let duration: Int64
}
