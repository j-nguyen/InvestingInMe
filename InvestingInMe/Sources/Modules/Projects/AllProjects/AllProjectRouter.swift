//
//  AllProjectRouter.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-22.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class AllProjectRouter {
  public enum Routes: String {
    case projectDetail
    case createProject
    case filterProjects
    case searchProjects
  }
}

extension AllProjectRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .createProject:
      context.drawerViewController?.presentViewController(CreateProjectAssembler.make())
    case .projectDetail:
      guard let params = parameters, let projectId = params["id"] as? Int else { return }
      context.drawerViewController?.presentViewController(ProjectDetailAssembler.make(projectId: projectId), animated: true)
      break
    case .filterProjects:
      context.navigationController?.pushViewController(FilterProjectAssembler.make(), animated: true)
    case .searchProjects:
      context.navigationController?.pushViewController(SearchProjectAssembler.make(), animated: true)
    }
  }
}
