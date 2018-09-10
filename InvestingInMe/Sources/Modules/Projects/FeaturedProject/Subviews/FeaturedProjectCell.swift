//
//  FeaturedProjectCell.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import Nuke
import RxSwift
import SnapKit
import MaterialComponents
import RxOptional
import RxNuke

public class FeaturedProjectCell: UITableViewCell {
  // MARK: Publish Subjects
  public var projectTitle = PublishSubject<String>()
  public var projectCategory = PublishSubject<String>()
  public var projectRole = PublishSubject<String>()
  public var projectDescription = PublishSubject<String>()
  public var projectImage = PublishSubject<URL>()
  
  // MARK: Views
  private var projectTitleLabel: UILabel!
  private var projectCategoryLabel: UILabel!
  private var projectRoleLabel: UILabel!
  private var projectDescriptionLabel: UILabel!
  private var projectImageView: UIImageView!
  private var inkViewController: MDCInkTouchController!
  
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
    inkViewController.cancelInkTouchProcessing()
    inkViewController.defaultInkView.cancelAllAnimations(animated: false)
    disposeBag = DisposeBag()
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareImageView()
    prepareTitleLabel()
    prepareCategoryLabel()
    prepareRoleLabel()
    prepareDescriptionLabel()
    prepareInkView()
  }
  
  private func prepareTitleLabel() {
    projectTitleLabel = UILabel()
    projectTitleLabel.font = MDCTypography.titleFont()
    
    contentView.addSubview(projectTitleLabel)
    
    projectTitleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.top.equalTo(contentView).inset(10)
      make.right.equalTo(contentView).inset(110)
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
    projectCategoryLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(projectCategoryLabel)
    
    projectCategoryLabel.snp.makeConstraints { make in
      make.top.equalTo(projectTitleLabel).offset(30)
      make.left.equalTo(contentView).offset(10)
      make.right.equalTo(contentView).inset(110)
    }
    
    projectCategory
      .asObservable()
      .bind(to: projectCategoryLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareRoleLabel() {
    projectRoleLabel = UILabel()
    projectRoleLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(projectRoleLabel)
    
    projectRoleLabel.snp.makeConstraints { make in
      make.top.equalTo(projectCategoryLabel).offset(25)
      make.left.equalTo(contentView).offset(10)
      make.right.equalTo(contentView).inset(110)
    }
    
    projectRole
      .asObservable()
      .bind(to: projectRoleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareDescriptionLabel() {
    projectDescriptionLabel = UILabel()
    projectDescriptionLabel.font = MDCTypography.body1Font()
    projectDescriptionLabel.numberOfLines = 3
    
    contentView.addSubview(projectDescriptionLabel)
    
    projectDescriptionLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(12.5)
      make.top.equalTo(projectRoleLabel).offset(30)
      make.right.equalTo(contentView).inset(110)
    }
    
    projectDescription
      .asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: projectDescriptionLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareImageView() {
    projectImageView = UIImageView()
    projectImageView.contentMode = .scaleAspectFit
    projectImageView.layer.masksToBounds = true
    projectImageView.layer.cornerRadius = 20
    
    contentView.addSubview(projectImageView)
    
    projectImageView.snp.makeConstraints { make in
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
      make.width.equalTo(80)
      make.height.equalTo(80)
    }
    
    projectImage
      .asObservable()
      .map { Nuke.Manager.shared.loadImage(with: $0).asObservable() }
      .flatMap { $0 }
      .bind(to: projectImageView.rx.image)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.addInkView()
  }
}
