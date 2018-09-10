//
//  CreateProjectAssembler.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-03.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct CreateProjectAssembler {
  public static func make() -> CreateProjectViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = CreateProjectViewModel(provider: provider)
    let router = CreateProjectRouter()
    return CreateProjectViewController(viewModel: viewModel, router: router)
  }
}
