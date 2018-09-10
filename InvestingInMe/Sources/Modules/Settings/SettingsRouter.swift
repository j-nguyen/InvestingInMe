//
//  SettingsRouter.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-19.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents
import GoogleSignIn

public struct SettingsRouter {
  public enum Routes: String {
    case login
    case disconnect
    case url
  }
}

extension SettingsRouter {
  public func route(to route: String, from context: UIViewController, parameters: [String: Any]? = nil) throws {
    guard let route = Routes(rawValue: route) else {
      throw RouteError.invalidRoute("Can't get route!")
    }
    
    switch route {
    case .login:
      let application = UIApplication.shared
      guard
        let delegate = application.delegate as? AppDelegate,
        let window = application.keyWindow
        else { return }
      
      // create the action
      let action = MDCAlertAction(title: "OK", handler: { _ in
        UserDefaults.standard.removeObject(forKey: "token")
        delegate.isLoggedIn.value = false
        window.rootViewController = LoginAssembler.make()
      })
      
      let confirmDialog = ModuleFactoryAssembler.makeConfirmationDialog(action: action)
      
      context.present(confirmDialog, animated: true)
    case .disconnect:      
      // create action, and attempt to disconnect if success
      let action = MDCAlertAction(title: "OK", handler: { _ in
        GIDSignIn.sharedInstance().disconnect()
      })
      
      let confirmDialog = ModuleFactoryAssembler.makeConfirmationDialog(action: action)
      
      context.present(confirmDialog, animated: true)
    case .url:
      guard
        let params = parameters,
        let title = params["title"] as? String,
        let url = params["url"] as? URL else {
          return
      }
      let vc = DocumentAssembler.make(title: title, url: url)
      context.present(vc, animated: true)
    }
  }
}
