//
//  FilterProjectCell.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-27.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents
import RxOptional

public class FilterProjectCell: UITableViewCell {
  
  private var projectLabel: UILabel!
  private var projectImageView: UIImageView!
  public var name = PublishSubject<String>()
  public var projectImage = PublishSubject<Bool>()
  
  public var disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    prepareImageView()
    prepareLabel()
  }
  
  private func prepareImageView() {
    projectImageView = UIImageView()
    projectImageView.contentMode = .scaleAspectFit
    projectImageView.image = UIImage(named: Constants.Icon.done)?.withRenderingMode(.alwaysTemplate)
    contentView.addSubview(projectImageView)
    
    
    projectImageView.snp.makeConstraints { make in
      make.right.equalTo(contentView).inset(20)
      make.centerY.equalTo(contentView)
    }
    
    projectImage
      .asObservable()
      .map { !$0 }
      .bind(to: projectImageView.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
  
  
  private func prepareLabel() {
    projectLabel = UILabel()
    projectLabel.font = MDCTypography.body1Font()
    contentView.addSubview(projectLabel)
    projectLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    name
      .asObservable()
      .bind(to: projectLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
}

