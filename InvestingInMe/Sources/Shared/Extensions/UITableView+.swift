//
//  UITableView+.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-08.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import UIKit

/// this registers the cell, and returns the type back too. This will make it easier for us to check for guards
extension UITableView {
  public func registerCell<T: UITableViewCell>(_: T.Type) {
    register(T.self, forCellReuseIdentifier: String(describing: T.self))
  }
  
  public func dequeueCell<T>(ofType type: T.Type, for indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
  }
  
  public func dequeueSingleCell<T>(ofType type: T.Type) -> T {
    return dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
  }
}
