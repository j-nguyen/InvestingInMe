//
//  FilteredProjectAssembler.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-05.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct FilteredProjectAssembler {
  public static func make(categories: [String], roles: [String]) -> FilteredProjectViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = FilteredProjectViewModel(provider: provider, categories: categories, roles: roles)
    let router = FilteredProjectRouter()
    
    return FilteredProjectViewController(viewModel: viewModel, router: router)
  }
}
