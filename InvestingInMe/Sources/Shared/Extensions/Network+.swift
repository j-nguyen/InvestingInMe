//
//  Network.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-17.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya
import JWTDecode
import GoogleSignIn
import MaterialComponents
import UIKit

// Extensions to make sure it's set for us
public struct Network {
  
  /// This endpoint closure will check the token before checking the request
  public static let endpointClosure = { (target: InvestingInMeAPI) -> Endpoint in
    let defaultEndpoint = MoyaProvider<InvestingInMeAPI>.defaultEndpointMapping(for: target)
    switch target {
    case .login:
      break
    default:
      // here we want to make sure and check that token isn't expired, but if it is we'll have to log them out
      do {
        if let token = UserDefaults.standard.string(forKey: "token") {
          let jwt = try decode(jwt: token)
          
          if jwt.expired {
            let window = UIApplication.shared.keyWindow
            window?.rootViewController = LoginAssembler.make()
            
            // create an alert
            let alertController = ModuleFactoryAssembler.makeLoginExpiredDialog()
            
            window?.rootViewController?.present(alertController, animated: true)
            
            return defaultEndpoint
          } else {
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": UserDefaults.standard.string(forKey: "token")!])
          }
          
        }
      } catch {
        return defaultEndpoint
      }
    }
    
    return defaultEndpoint
  }
}
