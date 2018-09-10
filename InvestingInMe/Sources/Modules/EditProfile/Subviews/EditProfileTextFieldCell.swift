//
//  EditProfileTextFieldCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift
import RxCocoa

public class EditProfileTextFieldCell: UITableViewCell {
  // MARK: Properties
  public let title = PublishSubject<String>()
  public let placeholder = PublishSubject<String>()
  public let value = PublishSubject<String>()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private(set) var textField: UITextField!
  
  public var textValue: ControlProperty<String?> {
    return textField.rx.text
  }
  
  public var keyboardType: UIKeyboardType = .default {
    didSet {
      textField.keyboardType = keyboardType
    }
  }
  
  public var editingDidChanged: ControlEvent<Void> {
    return textField.rx.controlEvent(.editingChanged)
  }
  
  private(set) var disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareTitleLabel()
    prepareTextField()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.titleFont()
    titleLabel.textColor = .black
    titleLabel.numberOfLines = 2
    
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
  
  private func prepareTextField() {
    textField = UITextField()
    textField.textAlignment = .left
    textField.font = MDCTypography.subheadFont()
    
    contentView.addSubview(textField)
    
    textField.snp.makeConstraints { make in
      make.left.equalTo(titleLabel.snp.right).offset(10)
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
    
    value
      .asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
    
    placeholder
      .asObservable()
      .bind(to: textField.rx.placeholder)
      .disposed(by: disposeBag)
  }
}
