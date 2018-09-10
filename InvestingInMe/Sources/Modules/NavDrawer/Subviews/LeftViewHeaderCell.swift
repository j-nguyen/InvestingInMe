//
//  LeftViewHeaderCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-08.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents
import Nuke
import RxNuke

public class LeftViewHeaderCell: UITableViewCell {
  // MARK: Properties
  public var name: PublishSubject<String> = PublishSubject()
  public var profile: PublishSubject<URL> = PublishSubject()
  public var email: PublishSubject<String> = PublishSubject()
  
  private var profileImage: UIImageView!
  private var nameLabel: UILabel!
  private var emailLabel: UILabel!
  
  private let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    prepareEmailLabel()
    prepareNameLabel()
    prepareImageView()
    // Setup background colour
    contentView.backgroundColor = MDCPalette.red.tint700
    selectionStyle = .none
  
  }
  
  private func prepareEmailLabel() {
    emailLabel = UILabel()
    emailLabel.font = MDCTypography.body1Font()
    emailLabel.textColor = .white
    
    contentView.addSubview(emailLabel)
    
    emailLabel.snp.makeConstraints { make in
      make.centerX.equalTo(contentView)
      make.bottom.equalTo(contentView).offset(-5)
    }
    
    email
      .asObservable()
      .bind(to: emailLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareNameLabel() {
    nameLabel = UILabel()
    nameLabel.font = MDCTypography.body2Font()
    nameLabel.textColor = .white
    
    contentView.addSubview(nameLabel)
    
    nameLabel.snp.makeConstraints { make in
      make.top.equalTo(emailLabel.snp.top).offset(-20)
      make.centerX.equalTo(contentView)
    }
    
    name
      .asObservable()
      .bind(to: nameLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareImageView() {
    profileImage = UIImageView()
    profileImage.contentMode = .scaleAspectFit
    profileImage.layer.cornerRadius = 37.5
    profileImage.clipsToBounds = true
    
    contentView.addSubview(profileImage)
    
    profileImage.snp.makeConstraints { make in
      make.width.equalTo(75)
      make.height.equalTo(75)
      make.top.equalTo(nameLabel.snp.top).offset(-85)
      make.centerX.equalTo(contentView)
    }
    
    profile
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .map { Nuke.Manager.shared.loadImage(with: $0).asObservable() }
      .flatMap { $0 }
      .observeOn(MainScheduler.instance)
      .bind(to: profileImage.rx.image)
      .disposed(by: disposeBag)
  }
}
