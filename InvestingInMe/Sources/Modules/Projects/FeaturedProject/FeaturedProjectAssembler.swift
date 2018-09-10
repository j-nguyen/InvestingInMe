//
//  FeaturedProjectAssembler.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-08.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct FeaturedProjectAssembler {
  public static func make() -> FeaturedProjectViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = FeaturedProjectViewModel(provider: provider)
    let router = FeaturedProjectRouter()
    
    return FeaturedProjectViewController(viewModel: viewModel, router: router)
  }
}
