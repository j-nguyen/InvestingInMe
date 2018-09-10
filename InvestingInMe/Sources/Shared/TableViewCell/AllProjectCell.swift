//
//  AllProjectCell.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-22.
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

public class AllProjectCell: UITableViewCell {
  // MARK: PublishSubjects
  public let projectTitle = PublishSubject<String>()
  public let projectCategory = PublishSubject<String>()
  public let projectRole = PublishSubject<String>()
  public let projectImage = PublishSubject<URL?>()
  
  // MARK: Viewsz
  private var projectTitleLabel: UILabel!
  private var projectCategoryLabel: UILabel!
  private var projectRoleLabel: UILabel!
  private var projectImageView: UIImageView!
  private var inkViewController: MDCInkTouchController!
  
  private let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    inkViewController.cancelInkTouchProcessing()
    inkViewController.defaultInkView.cancelAllAnimations(animated: false)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareImageView()
    prepareTitleLable()
    prepareCategoryLabel()
    prepareRoleLabel()
    prepareInkView()
  }
  
  private func prepareRoleLabel() {
    projectRoleLabel = UILabel()
    projectRoleLabel.font = MDCTypography.body1Font()
    
    contentView.addSubview(projectRoleLabel)
    
    projectRoleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.bottom.equalTo(contentView).inset(10)
      make.right.equalTo(projectImageView).inset(50)
      make.top.equalTo(projectCategoryLabel).inset(40)
    }
    
    projectRole
      .asObservable()
      .map { "Looking For: \($0)"}
      .bind(to: projectRoleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareTitleLable() {
    projectTitleLabel = UILabel()
    projectTitleLabel.font = MDCTypography.titleFont()
    
    contentView.addSubview(projectTitleLabel)
    
    projectTitleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.top.equalTo(contentView).inset(10)
      make.right.equalTo(projectImageView).offset(50)
    }
    
    projectTitle
      .asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: projectTitleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareCategoryLabel() {
    projectCategoryLabel = UILabel()
    projectCategoryLabel.font = MDCTypography.body1Font()
    
    contentView.addSubview(projectCategoryLabel)
    
    projectCategoryLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.bottom.equalTo(contentView).inset(10)
      make.right.equalTo(projectImageView).inset(50)
      make.top.equalTo(projectTitleLabel).offset(10)
    }
    
    projectCategory
      .asObservable()
      .map { "Category: \($0)"}
      .bind(to: projectCategoryLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareImageView() {
    projectImageView = UIImageView()
    projectImageView.contentMode = .scaleAspectFit
    projectImageView.layer.masksToBounds = true
    projectImageView.layer.cornerRadius = 15
    
    contentView.addSubview(projectImageView)
    
    projectImageView.snp.makeConstraints { make in
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
      make.width.equalTo(60)
      make.height.equalTo(60)
    }
    
    projectImage
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .filterNil()
      .map { Nuke.Manager.shared.loadImage(with: $0).asObservable() }
      .flatMap { $0 }
      .observeOn(MainScheduler.instance)
      .bind(to: projectImageView.rx.image)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.addInkView()
  }
}
