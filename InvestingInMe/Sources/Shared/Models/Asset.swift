//
//  Asset.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct Asset: Decodable {
  public let id: Int
  public let project_icon: Bool
  public let file_name: String
  public let file_size: Int64
  public let public_id: String?
  public let file_type: String
  public let url: URL
}
