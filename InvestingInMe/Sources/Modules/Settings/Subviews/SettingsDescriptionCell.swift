//
//  SettingsDescriptionCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-20.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

public class SettingsDescriptionCell: UITableViewCell {
  // MARK: Properties
  private var inkViewController: MDCInkTouchController!
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.addInkView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
