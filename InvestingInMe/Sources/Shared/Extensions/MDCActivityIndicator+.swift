//
//  MDCActivityIndicator+.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-04-13.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import MaterialComponents
import RxSwift
import RxCocoa

extension Reactive where Base: MDCActivityIndicator {
  public var progress: Binder<Float> {
    return Binder(self.base) { activityIndicator, progress in
      activityIndicator.progress = progress
    }
  }
}
