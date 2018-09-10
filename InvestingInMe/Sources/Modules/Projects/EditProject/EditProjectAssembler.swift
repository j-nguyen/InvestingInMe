//
//  EditProjectAssembler.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-30.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct EditProjectAssembler {
  public static func make(projectId: Int, detailViewModel: ProjectDetailViewModel) -> EditProjectViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = EditProjectViewModel(provider: provider, projectId: projectId)
    let router = EditProjectRouter()
    let projectId = projectId
    return EditProjectViewController(viewModel: viewModel, detailViewModel: detailViewModel, router: router, projectId: projectId)
  }
}
