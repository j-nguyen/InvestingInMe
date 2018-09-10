//
//  CreateProjectCategoryCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources
import MaterialComponents

public class CreateProjectCategoryCell: UITableViewCell {
  // MARK: Publish Subjects
  public let categories: Variable<[Category]> = Variable([])
  public let title: PublishSubject<String> = PublishSubject()
  public let currentCategory: PublishSubject<Int> = PublishSubject()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private var textField: UITextField!
  private var toolBar: UIToolbar!
  private var doneButton: UIBarButtonItem!
  private var pickerView: UIPickerView!
  
  // Convenience operators
  public var categorySelected: Observable<Category> {
    return pickerView.rx.itemSelected
      .asObservable()
      .map { [weak self] index in return self?.categories.value[index.row] }
      .filterNil()
  }
  
  public var disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
//    disposeBag = DisposeBag()
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareTitleLabel()
    prepareDropdowns()
    prepareToolBar()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.titleFont()
    
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
  
  private func prepareToolBar() {
    toolBar = UIToolbar()
    toolBar.barStyle = .default
    toolBar.isTranslucent = true
    toolBar.sizeToFit()
    
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    doneButton = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
    
    doneButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.textField.resignFirstResponder()
      })
      .disposed(by: disposeBag)
    
    toolBar.items = [flexSpace, doneButton]
    
    textField.inputAccessoryView = toolBar
  }
  
  private func prepareDropdowns() {
    textField = UITextField()
    textField.isEnabled = true
    textField.tintColor = .clear
    textField.allowsEditingTextAttributes = false
    textField.textAlignment = .right
    textField.placeholder = "Click here to enter in your category"
    textField.font = MDCTypography.body1Font()
    pickerView = UIPickerView()
    
    contentView.addSubview(textField)
    
    textField.snp.makeConstraints { make in
      make.left.equalTo(titleLabel.snp.right).offset(15)
      make.right.equalTo(contentView).offset(-15)
      make.centerY.equalTo(contentView)
    }
    
    categories
      .asObservable()
      .bind(to: pickerView.rx.itemTitles) { _, item in
        return item.type
      }
      .disposed(by: disposeBag)
    
    categorySelected
      .map { $0.type }
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
    
    Observable.combineLatest(categories.asObservable(), currentCategory.asObservable())
      .map { data in
        return data.0.first(where: { (category) -> Bool in
          return category.id == data.1
        })
      }
      .filterNil()
      .map { $0.type }
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
    
    textField.inputView = pickerView
  }
}
