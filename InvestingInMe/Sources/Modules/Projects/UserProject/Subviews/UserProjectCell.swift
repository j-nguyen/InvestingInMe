//
//  UserProjectCell.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
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

public class UserProjectCell: UITableViewCell {
  // MARK: Publish Subjects
  public var projectTitle = PublishSubject<String>()
  public var projectDescription = PublishSubject<String>()
  public var projectImage = PublishSubject<URL?>()
  
  // MARK: Views
  private var projectTitleLabel: UILabel!
  private var projectDescriptionLabel: UILabel!
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
    prepareDescriptionLabel()
    prepareInkView()
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
  
  private func prepareDescriptionLabel() {
    projectDescriptionLabel = UILabel()
    projectDescriptionLabel.font = MDCTypography.body1Font()
    projectDescriptionLabel.numberOfLines = 3
    
    contentView.addSubview(projectDescriptionLabel)
    
    projectDescriptionLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.bottom.equalTo(contentView).inset(10)
      make.right.equalTo(projectImageView).inset(50)
      make.top.equalTo(projectTitleLabel).offset(30)
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
    projectImageView.layer.cornerRadius = 12.5
    
    contentView.addSubview(projectImageView)
    
    projectImageView.snp.makeConstraints { make in
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
      make.width.equalTo(50)
      make.height.equalTo(50)
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
