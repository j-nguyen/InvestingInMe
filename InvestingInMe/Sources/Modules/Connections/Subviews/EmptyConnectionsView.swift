//
//  EmptyConnectionsView.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-22.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents

public class EmptyConnectionsView: UIView {
  
  // MARK: Labels
  private var connectionsTitleLabel: UILabel!
  private var connectionsDescriptionLabel: UILabel!
  
  // MARK: ImageView
  private var connectionsTitleImageView: UIImageView!
  
  // MARK: StackViews
  private var stackView: UIStackView!
  private var connectionsTitleStackView: UIStackView!
  
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
    connectionsTitleStackView = UIStackView()
    connectionsTitleStackView.axis = .horizontal
    connectionsTitleStackView.spacing = 5
    connectionsTitleStackView.distribution = .fill
    
    stackView.addArrangedSubview(connectionsTitleStackView)
  }
  
  //Prepare the Title Image
  private func prepareTitleImageView() {
    connectionsTitleImageView = UIImageView()
    connectionsTitleImageView.contentMode = .scaleAspectFit
    connectionsTitleImageView.image = UIImage(named: "ic_speaker_notes_off")?.withRenderingMode(.alwaysTemplate)
    connectionsTitleImageView.tintColor = .black
    
    connectionsTitleStackView.addArrangedSubview(connectionsTitleImageView)
    
    connectionsTitleImageView.snp.makeConstraints { (make) in
      make.height.equalTo(30)
      make.width.equalTo(30)
    }
  }
  
  //Prepare the Title Label
  private func prepareTitleLabel() {
    connectionsTitleLabel = UILabel()
    connectionsTitleLabel.font = MDCTypography.body2Font()
    connectionsTitleLabel.text = "No Contacts"
    
    connectionsTitleStackView.addArrangedSubview(connectionsTitleLabel)
  }
  
  //Prepare the Description Label
  private func prepareDescriptionLabel() {
    connectionsDescriptionLabel = UILabel()
    connectionsDescriptionLabel.font = MDCTypography.body2Font()
    connectionsDescriptionLabel.numberOfLines = 2
    connectionsDescriptionLabel.text = "You don't have any Contacts,  connect with someone new!"
    
    stackView.addArrangedSubview(connectionsDescriptionLabel)
    
  }
  
}
