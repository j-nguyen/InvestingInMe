//
//  NotificationWallAssembler.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-31.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya

public struct NotificationWallAssembler {
  
  public static func make() -> NotificationWallViewController {
    let viewModel = NotificationWallViewModel(provider: ModuleFactoryAssembler.makeMoya())
    let router = NotificationWallRouter()
    
    return NotificationWallViewController(viewModel: viewModel, router: router)
  }
}
