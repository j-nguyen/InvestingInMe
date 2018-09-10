//
//  UserProjectRouter.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class UserProjectRouter {
  public enum Routes: String {
    case projectDetail
    case createProject
  }
  fileprivate enum RouteError: Error {
    case invalidRoute(String)
  }
}

extension UserProjectRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .projectDetail:
      guard let params = parameters, let projectId = params["id"] as? Int else { return }
      
      context.drawerViewController?.presentViewController(ProjectDetailAssembler.make(projectId: projectId), animated: true)
      break
    case .createProject:
      context.drawerViewController?.presentViewController(CreateProjectAssembler.make())
    }
  }
}

