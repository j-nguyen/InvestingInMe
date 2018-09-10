//
//  UserProjectAssembler.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct UserProjectAssembler {
  public static func make() -> UserProjectViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = UserProjectViewModel(provider: provider)
    let router = UserProjectRouter()
    return UserProjectViewController(viewModel: viewModel, router: router)
  }
}
