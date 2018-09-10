//
//  NavigationCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-04-01.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import MaterialComponents

public class NavigationCell: UITableViewCell {
  // MARK: Properties
  public let title = PublishSubject<String>()
  public let iconImage = PublishSubject<UIImage?>()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private var iconView: UIImageView!
  private var inkTouchController: MDCInkTouchController!
  
  private let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareIconView()
    prepareTitleLabel()
    prepareInkView()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(iconView.snp.right).offset(10)
      make.right.equalTo(contentView)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareIconView() {
    iconView = UIImageView()
    iconView.contentMode = .scaleAspectFit
    iconView.tintColor = MDCPalette.grey.tint700
    
    contentView.addSubview(iconView)
    
    iconView.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.width.equalTo(25)
      make.height.equalTo(25)
      make.centerY.equalTo(contentView)
    }
    
    iconImage
      .asObservable()
      .bind(to: iconView.rx.image)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkTouchController = MDCInkTouchController(view: self)
    inkTouchController.addInkView()
  }
}
