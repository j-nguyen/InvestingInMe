//
//  SearchProjectAssembler.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct SearchProjectAssembler {
  
  public static func make() -> SearchProjectViewController {
    let viewModel = SearchProjectViewModel(provider: ModuleFactoryAssembler.makeMoya())
    let router = SearchProjectRouter()
    
    return SearchProjectViewController(viewModel: viewModel, router: router)
  }
}

