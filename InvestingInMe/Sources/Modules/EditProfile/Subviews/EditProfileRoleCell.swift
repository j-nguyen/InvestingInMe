//
//  EditProfileRoleCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-13.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SnapKit
import MaterialComponents
import RxCocoa
import RxDataSources
import Moya

public final class EditProfileRoleCell: UITableViewCell {
  public let editProfileRole: PublishSubject<Role?> = PublishSubject()
  
  // MARK: Views
  private var roleLabel: UILabel!
  private var profileRoleTextField: UITextField!
  public var roles: Variable<[Role]> = Variable([])
  private var rolePicker: UIPickerView!
  private var adapter: RxPickerViewStringAdapter<[Role]>!
  
  //MARK: ToolBar
  private var doneButton: UIBarButtonItem!
  private var toolbar: UIToolbar!
  
  //MARK: DisposeBag
  public let disposeBag: DisposeBag = DisposeBag()
  
  public var modelSelected: Observable<Role> {
    return rolePicker.rx.itemSelected.asObservable()
      .map { [weak self] (component, row) -> Role? in
        return self?.roles.value[component]
    }
    .filterNil()
  }
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareRoleLabel()
    prepareProfileRole()
    prepareRolePicker()
    prepareToolbar()
    
    contentView.rx.tapGesture()
      .asObservable()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.profileRoleTextField.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareRoleLabel() {
    roleLabel = UILabel()
    
    roleLabel.text = "Title"
    roleLabel.font = MDCTypography.titleFont()
    roleLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(roleLabel)
    
    roleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
  }
  
  private func prepareProfileRole() {
    profileRoleTextField = UITextField()
    
    profileRoleTextField.font = MDCTypography.subheadFont()
    profileRoleTextField.textColor = MDCPalette.grey.tint900
    profileRoleTextField.tintColor = .clear
    profileRoleTextField.allowsEditingTextAttributes = false
    profileRoleTextField.textAlignment = .left
    profileRoleTextField.placeholder = "Click on me to enter your role"
    
    contentView.addSubview(profileRoleTextField)
    
    profileRoleTextField.snp.makeConstraints { make in
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
    
    editProfileRole
      .asObservable()
      .filterNil()
      .map{ $0.role }
      .bind(to: profileRoleTextField.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareRolePicker() {
    rolePicker = UIPickerView()
    
    roles
      .asObservable()
      .bind(to: rolePicker.rx.itemTitles) {_, item in
        return item.role
      }.disposed(by: disposeBag)
    
    rolePicker.rx.itemSelected
      .asObservable()
      .map { [weak self] (component, row) -> Role? in
        return self?.roles.value[component]
    }
      .filterNil()
      .map { $0.role }
      .bind(to: profileRoleTextField.rx.text)
      .disposed(by: disposeBag)
    
    profileRoleTextField.inputView = rolePicker
  }
  
  private func prepareToolbar() {
    toolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.isTranslucent = true
    toolbar.sizeToFit()
    
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    doneButton = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
    
    doneButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
      guard let this = self else { return }
      this.profileRoleTextField.resignFirstResponder()
      })
      .disposed(by: disposeBag)
    
    toolbar.items = [flexSpace, doneButton]
    
    profileRoleTextField.inputAccessoryView = toolbar
  }
  
}
