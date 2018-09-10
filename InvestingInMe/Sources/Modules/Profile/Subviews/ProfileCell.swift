//
//  ProfileCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents
import RxOptional

public class ProfileCell: UITableViewCell {
  
  private var profileImageView: UIImageView!
  public var profileImage = PublishSubject<URL>()
  public var profileName = PublishSubject<String>()
  private var descriptionLabel: UILabel!
  public var descriptionText = PublishSubject<String>()
  private var locationLabel: UILabel!
  public var locationText = PublishSubject<String>()
  private var titleLabel: UILabel!
  public var titleText = PublishSubject<String>()
  private var emailLabel: UILabel!
  public var emailText = PublishSubject<String>()
  private var phoneNumberLabel: UILabel!
  public var phoneNumberText = PublishSubject<String>()
  private var experienceAndCredentialsLabel: UILabel!
  public var experienceAndCredentialsText = PublishSubject<String>()
  
  public var disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    prepareProfileImageView()
    //prepareProfileNameView()
    //prepareProfileDescriptionView()
    //prepareProfileLocationView()
    //prepareProfileTitleView()
    //prepareProfileEmailView()
    //prepareProfilePhoneView()
    //prepareProfileExperienceView()
  }
  
  private func prepareProfileImageView() {
    profileImageView = UIImageView()
    contentView.addSubview(profileImageView)
    profileImageView.snp.makeConstraints { make in
      make.centerX.equalTo(contentView)
      make.top.equalTo(50)
      make.width.equalTo(150)
      make.height.equalTo(150)
    }
    
    profileImage
      .asObservable()
      .map { image -> Data? in
        let data = try? Data(contentsOf: image)
        return data
    }
      .filterNil()
      .map { UIImage(data: $0) }
      .bind(to: profileImageView.rx.image)
      .disposed(by: disposeBag)
  }
}
