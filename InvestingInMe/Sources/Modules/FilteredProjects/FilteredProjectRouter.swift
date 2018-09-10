//
//  FilteredProjectRouter.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-05.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class FilteredProjectRouter {
  public enum Routes: String {
    case projectDetail
  }
}

extension FilteredProjectRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .projectDetail:
      guard let params = parameters, let projectId = params["id"] as? Int else { return }
      
      context.navigationController?.pushViewController(ProjectDetailAssembler.make(projectId: projectId), animated: true)
      break
    }
  }
}

