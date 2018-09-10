//
//  NavigationItem.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-04-01.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxDataSources

public enum NavigationItem {
  case deleteProject(order: Int, image: String, title: String)
  case featureProject(order: Int, image: String, title: String)
  case editProject(order: Int, image: String, title: String)
  case cancel(order: Int, image: String, title: String)
  
  public var order: Int {
    switch self {
      case let .deleteProject(order, _, _):
        return order
      case let .featureProject(order, _, _):
        return order
      case let .editProject(order, _, _):
        return order
      case let .cancel(order, _, _):
        return order
    }
  }
  
  public var image: String {
    switch self {
      case let .deleteProject(_, image, _):
        return image
      case let .featureProject(_, image, _):
        return image
      case let .editProject(_, image, _):
        return image
      case let .cancel(_, image, _):
        return image
    }
  }
  
  public var title: String {
    switch self {
    case let .deleteProject(_, _, title):
      return title
    case let .featureProject(_, _, title):
      return title
    case let .editProject(_, _, title):
      return title
    case let .cancel(_, _, title):
      return title
    }
  }
}

extension NavigationItem {
  public static func setupProjectDetailsMenu() -> [NavigationItem] {
    let items: [NavigationItem] = [
    .deleteProject(order: 0, image: Constants.Icon.delete, title: "Delete Project"),
    .featureProject(order: 1, image: Constants.Icon.feature, title: "Feature Project"),
    .editProject(order: 2, image: Constants.Icon.modeEdit, title: "Edit Project"),
    .cancel(order: 3, image: Constants.Icon.close, title: "Cancel")
    ]
    
    return items
  }
}
