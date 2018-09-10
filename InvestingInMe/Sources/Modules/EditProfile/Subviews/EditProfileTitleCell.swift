//
//  EditProfileTitleCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-27.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents

public class EditProfileTitleCell: UITableViewCell {
  // MARK: Properties
  public let title = PublishSubject<String>()
  
  private var titleLabel: UILabel!
  
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
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareTitleLabel()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.titleFont()
    titleLabel.textColor = .black
    
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
}
