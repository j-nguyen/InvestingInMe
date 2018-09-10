//
//  ProfileRouter.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public class ProfileRouter {
  public enum Routes: String {
    case profile
  }
  
  fileprivate enum RouteError: Error {
    case invalidRoute(String)
  }
}

extension ProfileRouter {
  public func route(from context: ProfileViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard Routes(rawValue: route) != nil else {
      throw RouteError.invalidRoute("This is an invalid route!")
    }
    
    guard let params = parameters,
      let userId = params["user_id"] as? Int,
      let viewModel = params["viewModel"] as? ProfileViewModel else { return }
    
    context.present(EditProfileAssembler.make(userId: userId, profileViewModel: viewModel), animated: true, completion: nil)
  }
}
