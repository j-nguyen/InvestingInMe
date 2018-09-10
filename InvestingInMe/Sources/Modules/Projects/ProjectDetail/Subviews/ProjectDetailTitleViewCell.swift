//
//  ProjectDetailDescriptionCell.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-19.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents
import RxOptional

public class ProjectDetailTitleViewCell: UITableViewCell {
  // MARK: Properties
  public let title = PublishSubject<String>()
  
  // MARK: Views
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
    titleLabel.textColor = MDCPalette.grey.tint800
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    title.asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
}

