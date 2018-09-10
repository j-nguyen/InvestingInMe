//
//  SettingsSwitchCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-04-07.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift
import RxCocoa

public class SettingsSwitchCell: UITableViewCell {
  // MARK: Properties
  public let title = PublishSubject<String>()
  public let isOn = PublishSubject<Bool>()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private var switchView: UISwitch!
  
  // MARK: Conveience operators
  public var value: ControlEvent<Bool> {
    return switchView.rx.isOn.changed.asControlEvent()
  }
  
  // MARK: Disposeable
  public var disposeable: Disposable! {
    didSet {
      disposeables.append(disposeable)
    }
  }
  
  private var disposeables: [Disposable] = []
  private let disposeBag = DisposeBag()
  
  public func disposeAll() {
    for disposeable in disposeables {
      disposeable.dispose()
    }
    disposeables.removeAll()
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
    prepareTitleLabel()
    prepareSwitchView()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(15)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareSwitchView() {
    switchView = UISwitch()
    
    contentView.addSubview(switchView)
    
    switchView.snp.makeConstraints { make in
      make.right.equalTo(contentView).offset(-15)
      make.centerY.equalTo(contentView)
    }
    
    isOn
      .asObservable()
      .bind(to: switchView.rx.isOn)
      .disposed(by: disposeBag)
  }
}
