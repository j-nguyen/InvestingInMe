//
//  SendMessageAssembler.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public final class SendMessageAssembler {
  //Declare the SendMessage Assembler
  public static func make(userId: Int) -> SendMessageViewController {
    let provider = ModuleFactoryAssembler.makeMoya()
    let viewModel = SendMessageViewModel(provider: provider, userId: userId)
    
    return SendMessageViewController(viewModel: viewModel)
  }
}
