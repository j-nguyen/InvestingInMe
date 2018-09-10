//
//  SettingsAssembler.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-19.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct SettingsAssembler {
  public static func make() -> SettingsViewController {
    let viewModel = SettingsViewModel(provider: ModuleFactoryAssembler.makeMoya())
    let router = SettingsRouter()
    
    return SettingsViewController(viewModel: viewModel, router: router)
  }
}
