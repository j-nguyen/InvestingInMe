//
//  ConnectionsRouter.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-20.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit

public class ConnectionsRouter {
  public enum Routes: String {
    case connections
    case connectionProfile
  }
}

extension ConnectionsRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]?) throws {
    
    guard let route = Routes(rawValue: route) else {
      throw RouteError.invalidRoute("This is an invalid route!") }
    
    switch route {
      case .connectionProfile:
        guard let params = parameters, let userId = params["userId"] as? Int else {
          throw RouteError.invalidRoute("Invalid parameters!")
        }
        context.drawerViewController?.presentViewController(ProfileAssembler.make(userId: userId), animated: true)
        break
      
      case .connections:
        guard let params = parameters,
        let user_id = params["userId"] as? Int else { return }
        
        context.present(ConnectionsAssembler.make(user_id: user_id), animated: true, completion: nil)
    }
  }
}
