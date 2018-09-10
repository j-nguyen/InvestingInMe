//
//  SendMessageCell.swift
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

public final class SendMessageCell: UITableViewCell {
  
  private var messageLabel: UILabel!
  private var messageTextField: UITextView!
  public var message: PublishSubject<String> = PublishSubject()
  
  //Placeholder Variable string
  private var placeholderText: Variable<String> = Variable("")
  
  // conveience operator
  public var textControl: ControlProperty<String> {
    return messageTextField.rx.text.orEmpty
  }
  
  public var textValue: ControlProperty<String?> {
    return messageTextField.rx.text
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
    prepareMessageLabel()
    prepareMessageTextField()
  }
  
  private func prepareMessageLabel() {
    messageLabel = UILabel()
    
    messageLabel.text = "Message"
    messageLabel.font = MDCTypography.titleFont()
    messageLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(messageLabel)
    
    messageLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(20)
      make.top.equalTo(contentView.snp.top)
    }
  }
  
  private func prepareMessageTextField() {
    messageTextField = UITextView()
    
    messageTextField.font = MDCTypography.subheadFont()
    messageTextField.textColor = .lightGray
    messageTextField.textAlignment = .left
    
    messageTextField.layer.borderColor = MDCPalette.grey.tint400.cgColor
    messageTextField.layer.borderWidth = 2
    messageTextField.layer.cornerRadius = 5.0
    messageTextField.textContainerInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    
    
    contentView.addSubview(messageTextField)
    
    messageTextField.snp.makeConstraints { make in
      make.top.equalTo(messageLabel.snp.bottom).offset(10)
      make.left.equalTo(contentView).offset(25)
      make.right.equalTo(contentView).inset(25)
      make.bottom.equalTo(contentView.snp.bottom)
      make.height.equalTo(150)
    }
    
    messageTextField.keyboardType = UIKeyboardType.alphabet
    
    let placeholderShare = message.asObservable().share()

    placeholderShare
      .map { $0.decode }
      .filterNil()
      .bind(to: messageTextField.rx.text)
      .disposed(by: disposeBag)
    
    placeholderShare
      .map { $0.decode }
      .filterNil()
      .bind(to: placeholderText).disposed(by: disposeBag)
    
    messageTextField.rx.didBeginEditing
      .asObservable()
      .subscribe(onNext: { [weak self] in
        if self?.messageTextField.textColor == .lightGray {
          self?.messageTextField.text = nil
          self?.messageTextField.textColor = .black
        }
      }).disposed(by: disposeBag)
    
    messageTextField.rx.didEndEditing
      .asObservable()
      .subscribe(onNext: { [weak self] in
        if self?.messageTextField.text.isEmpty ?? false {
          self?.messageTextField.text = self?.placeholderText.value
          self?.messageTextField.textColor = UIColor.lightGray
        }
      })
      .disposed(by: disposeBag)
  }
}

extension SendMessageCell: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return false
  }
}
