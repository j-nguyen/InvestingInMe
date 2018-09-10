//
//  ProfileImageCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-10.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SnapKit
import MaterialComponents
import Nuke
import RxNuke

public final class ProfileImageCell: UITableViewCell {
  
  public var profileImage = PublishSubject<URL>()
  public var profileName: PublishSubject<String> = PublishSubject()
  
  private var profileImageView: UIImageView!
  private var profileNameLabel: UILabel!
  
  public let disposeBag: DisposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareProfileImage()
    prepareProfileName()
  }
  
  private func prepareProfileImage() {
    profileImageView = UIImageView()
    profileImageView.layer.cornerRadius = 37.5
    profileImageView.clipsToBounds = true
    
    contentView.addSubview(profileImageView)
    
    profileImageView.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(15)
      make.centerY.equalTo(contentView)
      make.width.equalTo(75)
      make.height.equalTo(75)
    }
    
    profileImage
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .map { Nuke.Manager.shared.loadImage(with: $0).asObservable() }
      .flatMap { $0 }
      .observeOn(MainScheduler.instance)
      .bind(to: profileImageView.rx.image)
      .disposed(by: disposeBag)
    
  }
  
  private func prepareProfileName() {
    profileNameLabel = UILabel()
    
    profileNameLabel.font = MDCTypography.headlineFont()
    profileNameLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(profileNameLabel)
    
    profileNameLabel.snp.makeConstraints { make in
      make.left.equalTo(profileImageView.snp.right).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    profileName
      .asObservable()
      .bind(to: profileNameLabel.rx.text)
      .disposed(by: disposeBag)
    
  }
  
}
