//
//  ProfileTextCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SnapKit
import MaterialComponents

public final class ProfileTextCell: UITableViewCell {
  // MARK: Properties
  public let title: PublishSubject<String> = PublishSubject()
  public let textValue: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private var textValueLabel: UILabel!
  
  private(set) var disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareTitleLabel()
    prepareValueLabel()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.numberOfLines = 2
    titleLabel.font = MDCTypography.titleFont()
    titleLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareValueLabel() {
    textValueLabel = UILabel()
    textValueLabel.numberOfLines = 2
    textValueLabel.textAlignment = .left
    textValueLabel.font = MDCTypography.subheadFont()
    textValueLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(textValueLabel)
    
    textValueLabel.snp.makeConstraints { make in
      make.left.equalTo(titleLabel.snp.right).offset(10)
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
    
    textValue
      .asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: textValueLabel.rx.text)
      .disposed(by: disposeBag)
  }
}

