//
//  SearchProjectRouter.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//


import Foundation
import UIKit
import MaterialComponents

public class SearchProjectRouter {
  public enum Routes: String {
    case projectDetail
    case filterProjects
  }
  fileprivate enum RouteError: Error {
    case invalidRoute(String)
  }
}

extension SearchProjectRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]?) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .projectDetail:
      guard let params = parameters, let projectId = params["id"] as? Int else { return }
      
      context.navigationController?.pushViewController(ProjectDetailAssembler.make(projectId: projectId), animated: true)
      break
    case .filterProjects:
      context.navigationController?.pushViewController(SearchProjectAssembler.make(), animated: true)
    }
  }
}


