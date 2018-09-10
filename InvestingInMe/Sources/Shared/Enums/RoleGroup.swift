//
//  RoleGroup.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public enum RoleGroup: String {
  case developer = "Developer"
  case marketer = "Marketer"
  case investor = "Investor"
  case businessPerson = "Business Person"
  case finance = "Finance"
  public static var allValues = [RoleGroup.developer, RoleGroup.marketer, RoleGroup.investor, RoleGroup.businessPerson, RoleGroup.finance]
}
