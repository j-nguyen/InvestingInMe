//
//  FilterProjectRouter.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-27.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit

public class FilterProjectRouter {
  public enum Routes: String {
    case filteredProjects
  }
}

extension FilterProjectRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .filteredProjects:
      guard let params = parameters, let categories = params["categories"] as? [String], let roles = params["roles"] as? [String] else {
        throw RouteError.invalidRoute("Could not get params")
      }
      context.drawerViewController?.presentViewController(FilteredProjectAssembler.make(categories: categories, roles: roles), animated: true)
    }
  }
}
