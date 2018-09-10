//
//  ProfileButtonView.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-29.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents

public class ProfileButtonView: UIView {
  // MARK: Properties
  private var titleLabel: UILabel!
  private var imageView: UIImageView!
  private var inkViewController: MDCInkTouchController!
  
  public convenience init() {
    self.init(frame: .zero)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  private func prepareView() {
    backgroundColor = .darkBlue
    prepareImageView()
    prepareTitleLabel()
    prepareInkView()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.subheadFont()
    titleLabel.textColor = .white
    titleLabel.text = "User Profile"
    
    addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(imageView.snp.right).offset(10)
      make.centerY.equalTo(self)
    }
  }
  
  private func prepareImageView() {
    imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: Constants.Icon.person)?.withRenderingMode(.alwaysTemplate)
    imageView.tintColor = .white
    
    addSubview(imageView)
    
    imageView.snp.makeConstraints { make in
      make.height.equalTo(35)
      make.width.equalTo(35)
      make.centerX.equalTo(self).offset(-50)
      make.centerY.equalTo(self)
    }
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.addInkView()
  }
}
