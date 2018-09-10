//
//  ViewProfileCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-07.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents
import RxOptional

public class ViewProfileCell: UITableViewCell {
  
  public var profileViewButton: UIButton!
  private var profileImageIcon: UIImageView!
  
  //MARK: PublishSubject
  public var profileId: PublishSubject<Int> = PublishSubject()
  
  // MARK: Variable
  public var receivedId: Variable<Int?> = Variable(nil)
  
  //Declare the disposeBag for Rx
  public let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareProfileButton()
  }
  
  private func prepareProfileButton() {
    profileViewButton = UIButton()
    profileImageIcon = UIImageView()
    
    profileViewButton.isHidden = true
    profileImageIcon.isHidden = true
    
    profileViewButton.setTitle("User Profile", for: .normal)
    profileViewButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    profileViewButton.backgroundColor = UIColor.darkBlue
    
    profileImageIcon = UIImageView()
    profileImageIcon.contentMode = .scaleAspectFit
    profileImageIcon.image = UIImage(named: Constants.Icon.person)?.withRenderingMode(.alwaysTemplate)
    profileImageIcon.tintColor = .white

    profileViewButton.addSubview(profileImageIcon)
    contentView.addSubview(profileViewButton)
    
    profileViewButton.snp.makeConstraints {make in
      make.height.equalTo(40)
      make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom)
      make.left.equalTo(contentView.snp.left)
      make.right.equalTo(contentView.snp.right)
      make.centerX.equalTo(contentView)
      make.top.equalTo(20)
    }
    
    profileImageIcon.snp.makeConstraints { make in
      make.height.equalTo(35)
      make.width.equalTo(35)
      make.centerY.equalTo(profileViewButton)
      make.centerX.equalTo(profileViewButton).dividedBy(2).inset(10)
    }

    profileId
      .asObservable()
      .bind(to: receivedId)
      .disposed(by: disposeBag)
  }
  
  public var viewProfileTap: Observable<Void> {
    return profileViewButton.rx.tap.asObservable()
  }
}
