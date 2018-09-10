//
//  EditProfileAssembler.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public final class EditProfileAssembler {
  //Declare the EditProfile View Controller navigatio
  public static func make(userId: Int, profileViewModel: ProfileViewModelProtocol) -> EditProfileViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = EditProfileViewModel(userId: userId, profileViewModel: profileViewModel, provider: provider)
    let router = EditProfileRouter()
    
    return EditProfileViewController(viewModel: viewModel, router: router)
  }
}
