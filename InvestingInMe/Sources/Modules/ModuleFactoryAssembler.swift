//
//  ModuleProvider.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-17.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya
import MaterialComponents
import JWTDecode

/**
 ModuleProvider is our factory pattern style class, that generates specific providers for us
*/
public struct ModuleFactoryAssembler {
  /// Presents a network provider from moya to set up for us to use
  public static func makeMoya() -> MoyaProvider<InvestingInMeAPI> {
    #if DEBUG
      let provider = MoyaProvider<InvestingInMeAPI>(endpointClosure: Network.endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true)])
    #else
      let provider = MoyaProvider<InvestingInMeAPI>(endpointClosure: Network.endpointClosure)
    #endif
    
    return provider
  }
  
  /// Creates a modal to create a login expired
  public static func makeLoginExpiredDialog() -> MDCAlertController {
    let alertController = MDCAlertController(title: "Login Expired", message: "Your login credentials have expired! Please log in again")
    let action = MDCAlertAction(title: "OK") { _ in
      UserDefaults.standard.removeObject(forKey: "token")
    }
    alertController.addAction(action)
    return alertController
  }
  
  /// Creates a confirmation dialog
  public static func makeConfirmationDialog(action: MDCAlertAction? = nil) -> MDCAlertController {
    let alertController = MDCAlertController(title: "Are you sure?", message: "This will log you off of the app.")
    // check if there's an action
    if let action = action {
      alertController.addAction(action)
      alertController.addAction(MDCAlertAction(title: "Cancel"))
    }
    
    return alertController
  }
  
  ///Creates a model to display a message to the user
  public static func makeMessageDialog(message: String) -> MDCAlertController {
    let alertController = MDCAlertController(title: "Message", message: message)
    let action = MDCAlertAction(title: "Close")
    alertController.addAction(action)
    
    return alertController
  }
  
  /// Creates a custom dialog message, specified the varadics
  public static func makeCustomDialog(title: String, message: String, actions: MDCAlertAction...) -> MDCAlertController {
    let alertController = MDCAlertController(title: title, message: message)
    
    // add in all the actions
    for action in actions {
      alertController.addAction(action)
    }
    
    return alertController
  }
  
  /// Create a snackbar message and display to the current view controller
  public static func makeSnackbarMessage(message: String) {
    let message = MDCSnackbarMessage(text: message)
    MDCSnackbarManager.show(message)
  }
  
  //Create a reference to the current user's ID so we don't repeat code
  public static func currentUserId() -> Int {
    let token = UserDefaults.standard.string(forKey: "token")
    let jwt = try? decode(jwt: token!)
    let currentUserId = jwt?.body["user_id"] as? Int
    return currentUserId!
  }
}
