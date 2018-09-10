//
//  Category.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public enum CategoryGroup: String {
  case game = "Game"
  case mobileApp = "Mobile App"
  case mobileGameApp = "Mobile Game App"
  case website = "Website"
  case desktop = "Desktop App"
  case other = "Other"
  public static var allValues = [CategoryGroup.game, CategoryGroup.mobileApp, CategoryGroup.mobileGameApp, CategoryGroup.website, CategoryGroup.desktop, CategoryGroup.other]
}
