//
//  BottomNavigationAssembler.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-04-01.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct BottomNavigationAssembler {
  public static func make(projectId: Int) -> BottomNavigationViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let projectDetailViewModel = ProjectDetailViewModel(provider: provider, projectId: projectId)
    let viewModel = BottomNavigationViewModel(provider: provider, projectDetailViewModel: projectDetailViewModel, projectId: projectId)
    let router = BottomNavigationRouter()
    return BottomNavigationViewController(viewModel: viewModel, router: router)
  }
}
