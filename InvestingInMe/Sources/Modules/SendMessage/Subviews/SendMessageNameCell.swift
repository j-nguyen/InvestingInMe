//
//  SendMessageNameCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import SnapKit
import MaterialComponents

public final class SendMessageNameCell: UITableViewCell {
  
  private var nameLabel: UILabel!
  private var userNameLabel: UILabel!
  public var userName: PublishSubject<String> = PublishSubject()
  
  public let disposeBag: DisposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareNameLabel()
    prepareName()
  }
  
  private func prepareNameLabel() {
    nameLabel = UILabel()
    
    nameLabel.text = "Recipient "
    nameLabel.font = MDCTypography.titleFont()
    nameLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(nameLabel)
    
    nameLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(20)
      make.centerY.equalTo(contentView)
    }
  }
  
  private func prepareName() {
    userNameLabel = UILabel()
    
    userNameLabel.font = MDCTypography.subheadFont()
    userNameLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(userNameLabel)
    
    userNameLabel.snp.makeConstraints { make in
      make.left.equalTo(nameLabel.snp.right).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    userName
      .asObservable()
      .bind(to: userNameLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
