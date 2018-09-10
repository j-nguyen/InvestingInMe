//
//  FilterProjectAssembler.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-27.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct FilterProjectAssembler {
  public static func make() -> FilterProjectViewController {
    let viewModel = FilterProjectViewModel(provider: ModuleFactoryAssembler.makeMoya())
    let router = FilterProjectRouter()
    
    return FilterProjectViewController(viewModel: viewModel, router: router)
  }
}
