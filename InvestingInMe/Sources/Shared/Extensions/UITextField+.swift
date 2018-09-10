//
//  UITextField+.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-05.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITextField {
  public var placeholder: Binder<String> {
    return Binder(self.base) { textfield, placeholder in
      textfield.placeholder = placeholder
    }
  }
}
