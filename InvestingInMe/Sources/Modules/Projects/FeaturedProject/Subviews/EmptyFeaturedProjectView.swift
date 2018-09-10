//
//  EmptyFeaturedProjectView.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents

public class EmptyFeaturedProjectView: UIView {
  
  // MARK: Labels
  private var requestTitleLabel: UILabel!
  private var requestDescriptionLabel: UILabel!
  
  // MARK: ImageView
  private var requestTitleImageView: UIImageView!
  
  // MARK: StackViews
  private var stackView: UIStackView!
  private var requestTitleStackView: UIStackView!
  
  public convenience init() {
    self.init(frame: .zero)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    prepareStackView()
    prepareTitleStackView()
    prepareTitleImageView()
    prepareTitleLabel()
    prepareDescriptionLabel()
  }
  
  //Prepare the stackview
  private func prepareStackView() {
    stackView = UIStackView()
    stackView.alignment = .center
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 10
    
    addSubview(stackView)
    
    stackView.snp.makeConstraints { (make) in
      make.center.equalTo(self)
    }
  }
  
  //Prepare the Title
  private func prepareTitleStackView() {
    requestTitleStackView = UIStackView()
    requestTitleStackView.axis = .horizontal
    requestTitleStackView.spacing = 5
    requestTitleStackView.distribution = .fill
    
    stackView.addArrangedSubview(requestTitleStackView)
  }
  
  //Prepare the Title Image
  private func prepareTitleImageView() {
    requestTitleImageView = UIImageView()
    requestTitleImageView.contentMode = .scaleAspectFit
    requestTitleImageView.image = UIImage(named: "ic_assignment_late")?.withRenderingMode(.alwaysTemplate)
    requestTitleImageView.tintColor = .black
    
    requestTitleStackView.addArrangedSubview(requestTitleImageView)
    
    requestTitleImageView.snp.makeConstraints { (make) in
      make.height.equalTo(30)
      make.width.equalTo(30)
    }
  }
  
  //Prepare the Title Label
  private func prepareTitleLabel() {
    requestTitleLabel = UILabel()
    requestTitleLabel.font = MDCTypography.body2Font()
    requestTitleLabel.text = "No Featured Projects"
    
    requestTitleStackView.addArrangedSubview(requestTitleLabel)
  }
  
  //Prepare the Description Label
  private func prepareDescriptionLabel() {
    requestDescriptionLabel = UILabel()
    requestDescriptionLabel.font = MDCTypography.body2Font()
    requestDescriptionLabel.numberOfLines = 2
    requestDescriptionLabel.text = "No Projects Right Now, Check Back Later!"
    
    stackView.addArrangedSubview(requestDescriptionLabel)
    
  }
  
}

