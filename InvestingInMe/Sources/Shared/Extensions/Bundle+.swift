//
//  Bundle+.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-20.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

extension Bundle {
  public static var versionNumber: String? {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  public static var buildNumber: String? {
    return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
  }
}
