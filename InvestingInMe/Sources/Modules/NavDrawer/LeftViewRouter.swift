//
//  LeftViewRouter.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import JWTDecode

public struct LeftViewRouter {
  public enum Routes: String {
    case featuredProjects
    case profile
    case apps
    case myApps
    case addApp
    case connections
    case notifications
    case settings
    
    static let allValues = [
      ["Profile", Routes.profile.rawValue],
      ["Featured Projects", Routes.featuredProjects.rawValue],
      ["View Projects", Routes.apps.rawValue],
      ["My Projects", Routes.myApps.rawValue],
      ["Add Project", Routes.addApp.rawValue],
      ["Connections", Routes.connections.rawValue],
      ["Notifications", Routes.notifications.rawValue],
      ["Settings", Routes.settings.rawValue]
    ]
  }
}

extension LeftViewRouter {
  public func route(to route: String, from context: UIViewController, parameters: [String: Any]? = nil) throws {
    guard let route = Routes(rawValue: route) else {
      throw RouteError.invalidRoute("Can't get route!")
    }

    switch route {
    case .featuredProjects:
      context.drawerViewController?.setViewController(FeaturedProjectAssembler.make(), animated: false)
    case .myApps:
      context.drawerViewController?.setViewController(UserProjectAssembler.make(), animated: false)
    case .profile:
      guard
        let token = UserDefaults.standard.string(forKey: "token"),
        let jwt = try? decode(jwt: token),
        let userId: Int = jwt.body["user_id"] as? Int else {
          return
      }
      context.drawerViewController?.setViewController(ProfileAssembler.make(userId: userId), animated: false)
    case .settings:
      // make sure to set the information in here
      context.drawerViewController?.setViewController(SettingsAssembler.make(), animated: false)
      break
    case .apps:
      context.drawerViewController?.setViewController(AllProjectAssembler.make(), animated: false)
    case .addApp:
      context.drawerViewController?.setViewController(CreateProjectAssembler.make(), animated: false)
    case .connections:
      guard
        let token = UserDefaults.standard.string(forKey: "token"),
        let jwt = try? decode(jwt: token),
        let userId: Int = jwt.body["user_id"] as? Int else {
          return
      }
      context.drawerViewController?.setViewController(ConnectionsAssembler.make(user_id: userId), animated: false)
    case .notifications:
      context.drawerViewController?.setViewController(NotificationWallAssembler.make(), animated: false)
    }
  }
}
