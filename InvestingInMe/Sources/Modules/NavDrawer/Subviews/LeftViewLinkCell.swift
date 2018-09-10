//
//  LeftViewLinkCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import MaterialComponents

public final class LeftViewLinkCell: UITableViewCell {
  // MARK: Properties
  public var name: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var nameLabel: UILabel!
  private var inkView: MDCInkTouchController!
  
  private let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    prepareNameLabel()
    prepareInkView()
    
    contentView.backgroundColor = MDCPalette.grey.tint300
    selectionStyle = .none
  }
  
  /// Prepares the Name Label itself
  private func prepareNameLabel() {
    nameLabel = UILabel()
    nameLabel.font = MDCTypography.buttonFont()
    nameLabel.textColor = MDCPalette.grey.tint700
    
    contentView.addSubview(nameLabel)
    
    nameLabel.snp.makeConstraints { make in
      make.centerY.equalTo(contentView)
      make.left.equalTo(contentView).offset(10)
    }
    
    name
      .asObservable()
      .bind(to: nameLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  /// prepares the ink view
  private func prepareInkView() {
    inkView = MDCInkTouchController(view: self)
    inkView.delegate = self
    inkView.addInkView()
  }
}

// MARK: InkExtension
extension LeftViewLinkCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}
