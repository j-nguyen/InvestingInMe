//
//  ConnectionsAssembler.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-20.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct ConnectionsAssembler {
  
  public static func make(user_id: Int) -> ConnectionsViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = ConnectionsViewModel(provider: provider, userId: user_id)
    let router = ConnectionsRouter()
    
    return ConnectionsViewController(viewModel: viewModel, router: router)
  }
}
