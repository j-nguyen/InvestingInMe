//
//  ProjectDetailAssembler.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct ProjectDetailAssembler {
  public static func make(projectId: Int) -> ProjectDetailViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = ProjectDetailViewModel(provider: provider, projectId: projectId)
    let bottomNavigationController = BottomNavigationViewController(viewModel: BottomNavigationViewModel(provider: provider, projectDetailViewModel: viewModel, projectId: projectId),router: BottomNavigationRouter())
    let router = ProjectDetailRouter()
    
    return ProjectDetailViewController(viewModel: viewModel, bottomNavigationController: bottomNavigationController, router: router)
  }
}

