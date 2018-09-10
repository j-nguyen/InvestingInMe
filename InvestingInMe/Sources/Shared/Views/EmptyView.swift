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

public class EmptyView: UIView {
  
  // MARK: Labels
  private var titleLabel: UILabel!
  private var descriptionLabel: UILabel!
  
  // MARK: ImageView
  private var titleImageView: UIImageView!
  
  // MARK: StackViews
  private var stackView: UIStackView!
  private var titleStackView: UIStackView!
  
  // MARK: Properties
  private var imageLiteral: String!
  private var title: String!
  private var descriptionText: String!
  
  public convenience init(imageLiteral: String, title: String, descriptionText: String) {
    self.init(frame: .zero)
    self.imageLiteral = imageLiteral
    self.title = title
    self.descriptionText = descriptionText
    prepareView()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
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
    titleStackView = UIStackView()
    titleStackView.axis = .horizontal
    titleStackView.spacing = 5
    titleStackView.distribution = .fill
    
    stackView.addArrangedSubview(titleStackView)
  }
  
  //Prepare the Title Image
  private func prepareTitleImageView() {
    titleImageView = UIImageView()
    titleImageView.contentMode = .scaleAspectFit
    titleImageView.image = UIImage(named: imageLiteral)?.withRenderingMode(.alwaysTemplate)
    titleImageView.tintColor = .black
    
    titleStackView.addArrangedSubview(titleImageView)
    
    titleImageView.snp.makeConstraints { (make) in
      make.height.equalTo(30)
      make.width.equalTo(30)
    }
  }
  
  //Prepare the Title Label
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.body2Font()
    titleLabel.text = title
    
    titleStackView.addArrangedSubview(titleLabel)
  }
  
  //Prepare the Description Label
  private func prepareDescriptionLabel() {
    descriptionLabel = UILabel()
    descriptionLabel.lineBreakMode = .byWordWrapping
    descriptionLabel.font = MDCTypography.body2Font()
    descriptionLabel.numberOfLines = 2
    descriptionLabel.text = descriptionText
    
    stackView.addArrangedSubview(descriptionLabel)
    
  }
  
}


