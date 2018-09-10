//
//  EditProfileRouter.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import UIKit

//MARK: EditProfileRouter
public class EditProfileRouter {
  public enum Routes: String {
    case profile
  }
}

//MARK: EditProfileRouter Extension
extension EditProfileRouter {
  
  //Declare the routing for the EditProfileViewModel for convenience
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]? = nil) throws {
    
    //If the route is invalid, throw an error
    guard Routes(rawValue: route) != nil else {
      throw RouteError.invalidRoute("This is an invalid route!")
    }
    
    //Declare the parameters required
    guard let params = parameters,
      let userId = params["user_id"] as? Int,
      let viewModel = params["viewModel"] as? ProfileViewModel else { return }
    
    //Present the Edit Profile page
    context.present(EditProfileAssembler.make(userId: userId, profileViewModel: viewModel), animated: true, completion: nil)
  }
}
