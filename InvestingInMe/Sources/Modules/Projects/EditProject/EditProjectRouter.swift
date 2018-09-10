//
//  EditProjectRouter.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-30.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class EditProjectRouter {
  public enum Routes: String {
    case myProjects
    case project
  }
}

extension EditProjectRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
      case .myProjects:
      context.drawerViewController?.setViewController(UserProjectAssembler.make(), animated: true)
    case .project:
      guard let params = parameters, let projectId = params["projectId"] as? Int else { throw RouteError.invalidRoute("Invalid Parameters!") }
      context.drawerViewController?.setViewController(ProjectDetailAssembler.make(projectId: projectId), animated: true)
    }
  }
}
