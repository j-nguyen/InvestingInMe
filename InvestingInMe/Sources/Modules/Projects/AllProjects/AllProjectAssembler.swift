//
//  AllProjectAssembler.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-23.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct AllProjectAssembler {
  public static func make() -> AllProjectViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = AllProjectViewModel(provider: provider)
    let router = AllProjectRouter()
    
    return AllProjectViewController(viewModel: viewModel, router: router)
  }
}
