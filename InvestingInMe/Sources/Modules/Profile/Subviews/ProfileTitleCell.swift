//
//  ProfilePhoneCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SnapKit
import MaterialComponents

public final class ProfileTitleCell: UITableViewCell {
  // MARK: Properties
  public let title: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var titleLabel: UILabel!
  
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
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.titleFont()
    titleLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
