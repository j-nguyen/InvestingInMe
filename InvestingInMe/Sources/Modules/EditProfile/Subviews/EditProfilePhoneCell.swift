//
//  EditProfilePhoneCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-13.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import SnapKit
import MaterialComponents

public final class EditProfilePhoneCell: UITableViewCell {
  private var phoneLabel: UILabel!
  public var profilePhoneLabel: UITextField!
  public var profilePhone: PublishSubject<String> = PublishSubject()
  
  public var textValue: ControlProperty<String?> {
    return profilePhoneLabel.rx.text
  }
  
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
    preparePhoneLabel()
    prepareProfilePhone()
  }
  
  private func preparePhoneLabel() {
    phoneLabel = UILabel()
    
    phoneLabel.text = "Phone Number"
    phoneLabel.font = MDCTypography.titleFont()
    phoneLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(phoneLabel)
    
    phoneLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
  }
  
  private func prepareProfilePhone() {
    profilePhoneLabel = UITextField()
    
    profilePhoneLabel.font = MDCTypography.subheadFont()
    profilePhoneLabel.textColor = MDCPalette.grey.tint900
    profilePhoneLabel.placeholder = "Enter in your phone number"
    profilePhoneLabel.textAlignment = .right
    
    contentView.addSubview(profilePhoneLabel)
    
    profilePhoneLabel.snp.makeConstraints { make in
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
      
    profilePhoneLabel.keyboardType = UIKeyboardType.decimalPad

    profilePhone
      .asObservable()
      .bind(to: profilePhoneLabel.rx.text)
      .disposed(by: disposeBag)
    }
}

