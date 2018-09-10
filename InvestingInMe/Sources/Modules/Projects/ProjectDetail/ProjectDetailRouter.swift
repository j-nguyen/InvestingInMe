//
//  ProjectDetailRouter.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-16.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ImageViewer

public class ProjectDetailRouter {
  public enum Routes: String {
    case pageViewer
    case userProfile
    case sendMessage
    case myProjects
    case editProject
  }
}

extension ProjectDetailRouter {
  public func route(from context: UIViewController, to route: String, parameters: [String : Any]?) throws {
    
    guard let route = Routes(rawValue: route) else { throw RouteError.invalidRoute("Invalid route!") }
    
    switch route {
    case .pageViewer:
      guard
        let params = parameters,
        let assets = params["assets"] as? [Asset],
        let index = params["index"] as? Int else {
          throw RouteError.invalidRoute("Invalid Parameters!")
      }
      
      let dataSource = CustomGallerySource(assets)
      let items: [GalleryConfigurationItem] = [
        GalleryConfigurationItem.closeButtonMode(.builtIn),
        GalleryConfigurationItem.closeLayout(.pinLeft(10, 10)),
        GalleryConfigurationItem.seeAllCloseButtonMode(.none),
        GalleryConfigurationItem.statusBarHidden(true),
        GalleryConfigurationItem.thumbnailsButtonMode(.none),
        GalleryConfigurationItem.deleteButtonMode(.none),
        GalleryConfigurationItem.pagingMode(.carousel)
      ]
      let galleryViewController = GalleryViewController(startIndex: index, itemsDataSource: dataSource, configuration: items)
      
      // Launch an async
      DispatchQueue.main.async {
        context.present(galleryViewController, animated: true)
      }
      
    case .userProfile:
      guard let params = parameters, let userId = params["userId"] as? Int else { throw RouteError.invalidRoute("Invalid Parameters!") }
      context.drawerViewController?.presentViewController(ProfileAssembler.make(userId: userId), animated: true)
    case .sendMessage:
      guard let params = parameters, let userId = params["userId"] as? Int else { throw RouteError.invalidRoute("Invalid Parameters!") }
      context.present(SendMessageAssembler.make(userId: userId), animated: true)
    case .myProjects:
      context.drawerViewController?.setViewController(UserProjectAssembler.make(), animated: true)
    case .editProject:
      guard let params = parameters,
        let projectId = params["projectId"] as? Int,
        let viewModel = params["viewModel"]
          else { throw RouteError.invalidRoute("Invalid Parameters!") }
      context.present(EditProjectAssembler.make(projectId: projectId, detailViewModel: viewModel as! ProjectDetailViewModel), animated: true)
    }
  }
}
