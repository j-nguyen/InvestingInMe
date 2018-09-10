//
//  CreateProjectScreenshotTitleCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-21.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import MaterialComponents

public class CreateProjectScreenshotTitleCell: UITableViewCell {
  // MARK: Properties
  public let title: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private(set) var addButton: UIImageView!
  
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
    prepareTitleLabel()
    prepareAddButton()
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.titleFont()
    
    contentView.addSubview(titleLabel)
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
  }
  
  private func prepareAddButton() {
    addButton = UIImageView()
    addButton.image = UIImage(named: Constants.Icon.addCircle)?.withRenderingMode(.alwaysOriginal)
    
    contentView.addSubview(addButton)
    
    addButton.snp.makeConstraints { make in
      make.left.equalTo(titleLabel.snp.right).offset(10)
      make.centerY.equalTo(contentView)
    }
  }
}

