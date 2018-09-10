//
//  ProfileExperienceCell.swift
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

public final class ProfileTextViewCell: UITableViewCell {
  // MARK: Properties
  public let value: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var textView: UITextView!
  
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
    prepareTextView()
  }
  
  private func prepareTextView() {
    textView = UITextView()
    
    textView.font = MDCTypography.subheadFont()
    textView.textColor = MDCPalette.grey.tint900
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.textAlignment = .left
    
    contentView.addSubview(textView)
    
    textView.snp.makeConstraints { make in
      make.edges.equalTo(contentView).inset(5)
    }
    
    value
      .asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: textView.rx.text)
      .disposed(by: disposeBag)
  }
}
