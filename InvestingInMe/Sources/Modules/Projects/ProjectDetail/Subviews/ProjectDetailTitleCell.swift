//
//  ProjectDetailTitleCell.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents
import RxOptional
import Nuke
import RxNuke

public class ProjectDetailTitleCell: UITableViewCell {
  
  //MARK: Views
  private var projectTitleLabel: UILabel!
  private var projectImageView: UIImageView!
  public var contactView: UIView!
  public var contactLabel: UILabel!

  // MARK: PublishSubjects
  public var projectTitle = PublishSubject<String>()
  public var projectImage = PublishSubject<URL?>()
  
  // MARK: Disposable
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
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareImageView()
    prepareTitleLabel()
    prepareContactView()
    prepareContactText()
  }
  
  private func prepareTitleLabel() {
    projectTitleLabel = UILabel()
    projectTitleLabel.font = MDCTypography.titleFont()
    
    contentView.addSubview(projectTitleLabel)
    
    projectTitleLabel.snp.makeConstraints { make in
      make.left.equalTo(projectImageView.snp.right).offset(10)
      make.right.equalTo(contentView).offset(10)
      make.top.equalTo(contentView).offset(15)
    }
    
    projectTitle
      .asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: projectTitleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareImageView() {
    projectImageView = UIImageView()
    projectImageView.contentMode = .scaleAspectFit
    projectImageView.layer.masksToBounds = true
    projectImageView.layer.cornerRadius = 20
    
    contentView.addSubview(projectImageView)
    
    projectImageView.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.top.equalTo(contentView).inset(10)
      make.width.equalTo(80)
      make.height.equalTo(80)
    }
    
    projectImage
      .asObservable()
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .filterNil()
      .map { Nuke.Manager.shared.loadImage(with: $0).asObservable() }
      .flatMap { $0 }
      .observeOn(MainScheduler.instance)
      .bind(to: projectImageView.rx.image)
      .disposed(by: disposeBag)
  }
  
  private func prepareContactView() {
    contactView = UIView()
    contactView.layer.cornerRadius = 17.5
    contactView.backgroundColor = .darkBlue
    
    contentView.addSubview(contactView)
    
    contactView.snp.makeConstraints { make in
      make.left.equalTo(projectImageView.snp.right).offset(10)
      make.bottom.equalTo(contentView).inset(10)
      make.width.equalTo(contentView).dividedBy(2)
      make.height.equalTo(35)
    }
  }
  
  private func prepareContactText() {
    contactLabel = UILabel()
    contactLabel.font = MDCTypography.buttonFont()
    contactLabel.textColor = UIColor.white
    contactLabel.text = "Request Contact"
  
    contactView.addSubview(contactLabel)
    
    contactLabel.snp.makeConstraints { make in
      make.center.equalTo(contactView.snp.center)
    }
  }
}

