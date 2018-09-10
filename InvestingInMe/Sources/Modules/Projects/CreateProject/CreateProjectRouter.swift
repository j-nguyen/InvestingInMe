//
//  CreateProjectRouter.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-25.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class CreateProjectRouter {
  public enum Routes: String {
    case myProjects
  }
}

extension CreateProjectRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .myProjects:
      context.drawerViewController?.setViewController(UserProjectAssembler.make(), animated: true)
    }
  }
}
