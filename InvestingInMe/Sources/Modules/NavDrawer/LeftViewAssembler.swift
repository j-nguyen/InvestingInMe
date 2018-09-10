//
//  LeftViewAssembler.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-08.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct LeftViewAssembler {
  public static func make() -> LeftViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = LeftViewModel(provider: provider)
    let router = LeftViewRouter()
    
    return LeftViewController(viewModel: viewModel, router: router)
  }
}
