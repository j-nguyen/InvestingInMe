//
//  FeaturedProjectRouter.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class FeaturedProjectRouter {
  public enum Routes: String {
    case createProject
    case projectDetail
  }
}

extension FeaturedProjectRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .createProject:
      context.drawerViewController?.presentViewController(CreateProjectAssembler.make())
      break
    case .projectDetail:
      guard let params = parameters, let projectId = params["id"] as? Int else { return }
      
      context.drawerViewController?.presentViewController(ProjectDetailAssembler.make(projectId: projectId))
      break
    }
  }
}
