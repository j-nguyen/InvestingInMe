//
//  DocumentAssembler.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-04-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit

public struct DocumentAssembler {
  public static func make(title: String, url: URL, initial: Bool = false) -> UIViewController {
    let viewModel = DocumentViewModel(title: title, url: url, initial: initial)
    let vc = DocumentViewController(viewModel: viewModel)
    return UINavigationController(rootViewController: vc)
  }
}
