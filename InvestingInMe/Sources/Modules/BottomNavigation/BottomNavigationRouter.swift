//
//  BottomNavigationRouter.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-04-01.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class BottomNavigationRouter {
  public enum Route: String {
    case deleteProject
    case featureProject
    case editProject
    case cancel
  }
  
  public func route(from context: UIViewController, to: String, parameters: [String : Any]?) throws {
    guard let route = Route(rawValue: to) else {
      throw RouteError.invalidRoute("This is an invalid route!")
    }
    
    switch route {
    case .editProject:
      guard let params = parameters,
        let projectId = params["projectId"] as? Int,
        let viewModel = params["viewModel"] as? ProjectDetailViewModel
        else { throw RouteError.invalidRoute("Invalid Parameters!") }
      context.present(EditProjectAssembler.make(projectId: projectId, detailViewModel: viewModel), animated: true)
    default:
      break
    }
  }
}
