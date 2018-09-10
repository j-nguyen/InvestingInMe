//
//  CreateProjectNameCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-05.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import MaterialComponents
import SnapKit
import RxCocoa

public class CreateProjectNameCell: UITableViewCell {
  // MARK: Publishsubjects
  public let title: PublishSubject<String> = PublishSubject()
  public let placeholder: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private var nameTextField: UITextField!
  
  // Conveience operator
  public var textValue: ControlProperty<String?> {
    return nameTextField.rx.text
  }
  
  // MARK: Disposeable
  public var disposeable: Disposable! {
    didSet {
      disposeables.append(disposeable)
    }
  }
  
  private var disposeables: [Disposable] = []
  
  public func disposeAll() {
    for disposeable in disposeables {
      disposeable.dispose()
    }
    disposeables.removeAll()
  }
  
  private let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    prepareTitleLabel()
    prepareNameTextField()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.titleFont()
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    title.asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareNameTextField() {
    nameTextField = UITextField()
    nameTextField.textAlignment = .left
    nameTextField.font = MDCTypography.body1Font()
    
    
    contentView.addSubview(nameTextField)
    
    nameTextField.snp.makeConstraints { make in
      make.left.equalTo(titleLabel.snp.right).offset(10)
      make.right.equalTo(contentView).offset(-10)
      make.centerY.equalTo(contentView)
    }
    
    placeholder
      .asObservable()
      .bind(to: nameTextField.rx.placeholder)
      .disposed(by: disposeBag)
  }
}
