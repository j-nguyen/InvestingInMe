//
//  ProfileAssembler.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public struct ProfileAssembler {
  public static func make(userId: Int) -> ProfileViewController{
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = ProfileViewModel(provider: provider, userId: userId)
    let router = ProfileRouter()

    return ProfileViewController(viewModel: viewModel, router: router)
  }
}
