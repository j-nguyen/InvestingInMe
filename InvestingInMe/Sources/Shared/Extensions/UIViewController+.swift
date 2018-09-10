//
//  UIViewController+.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  /// Gets the Navigation drawer for us
  public var drawerViewController: NavigationDrawerViewController? {
    var current: UIViewController? = self
    
    while current != nil {
      if current is NavigationDrawerViewController {
        return current as? NavigationDrawerViewController
      }
      current = current?.parent
    }
    return nil
  }
}
