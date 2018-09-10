//
//  NotificationWallRouter.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-31.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class NotificationWallRouter {
  public enum Routes: String {
    case connections
  }
  fileprivate enum RouteError: Error {
    case invalidRoute(String)
  }
}

extension NotificationWallRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]?) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .connections:
      context.drawerViewController?.presentViewController(ConnectionsAssembler.make(user_id: ModuleFactoryAssembler.currentUserId()), animated: true)
    }
  }
}
