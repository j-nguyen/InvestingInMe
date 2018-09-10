//
//  EmptySentView.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-22.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents

public class EmptySentView: UIView {
  
  // MARK: Labels
  private var sentTitleLabel: UILabel!
  private var sentDescriptionLabel: UILabel!
  
  // MARK: ImageView
  private var sentTitleImageView: UIImageView!
  
  // MARK: StackViews
  private var stackView: UIStackView!
  private var sentTitleStackView: UIStackView!
  
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
    sentTitleStackView = UIStackView()
    sentTitleStackView.axis = .horizontal
    sentTitleStackView.spacing = 5
    sentTitleStackView.distribution = .fill
    
    stackView.addArrangedSubview(sentTitleStackView)
  }
  
  //Prepare the Title Image
  private func prepareTitleImageView() {
    sentTitleImageView = UIImageView()
    sentTitleImageView.contentMode = .scaleAspectFit
    sentTitleImageView.image = UIImage(named: "ic_speaker_notes_off")?.withRenderingMode(.alwaysTemplate)
    sentTitleImageView.tintColor = .black
    
    sentTitleStackView.addArrangedSubview(sentTitleImageView)
    
    sentTitleImageView.snp.makeConstraints { (make) in
      make.height.equalTo(30)
      make.width.equalTo(30)
    }
  }
  
  //Prepare the Title Label
  private func prepareTitleLabel() {
    sentTitleLabel = UILabel()
    sentTitleLabel.font = MDCTypography.body2Font()
    sentTitleLabel.text = "No Sent Requests"
    
    sentTitleStackView.addArrangedSubview(sentTitleLabel)
  }
  
  //Prepare the Description Label
  private func prepareDescriptionLabel() {
    sentDescriptionLabel = UILabel()
    sentDescriptionLabel.font = MDCTypography.body2Font()
    sentDescriptionLabel.numberOfLines = 2
    sentDescriptionLabel.text = "No sent requests out right now, add a new Contact!"
    
    stackView.addArrangedSubview(sentDescriptionLabel)
    
  }
  
}

