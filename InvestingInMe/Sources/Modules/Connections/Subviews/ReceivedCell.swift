//
//  ReceivedCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-23.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import MaterialComponents
import RxSwift
import SnapKit
import Nuke
import RxNuke

public final class ReceivedCell: UITableViewCell {
  
  //MARK: InkViewController
  private var inkViewController: MDCInkTouchController!
  
  //MARK: Publish Subjects
  public let userImage: PublishSubject<URL> = PublishSubject()
  public let userName: PublishSubject<String> = PublishSubject()
  public let userRole: PublishSubject<Role?> = PublishSubject()
  
  // MARK: Variable
  public var receivedName: Variable<String?> = Variable(nil)
  
  //MARK: Labels
  private var userImageView: UIImageView!
  private var userNameLabel: UILabel!
  private var userRoleLabel: UILabel!
  public var acceptButton: UIButton!
  public var acceptImage: UIImageView!
  public var declineButton: UIButton!
  public var declineImage: UIImageView!
  
  //MARK: DisposeBags
  public var dispose: Disposable! {
    didSet {
      disposables.append(dispose)
    }
  }
  
  private var disposables: [Disposable] = []
  
  private func disposeAll() {
    for dispose in disposables {
      dispose.dispose()
    }
    disposables.removeAll()
  }
  
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
    disposeAll()
  }
  
  private func prepareView() {
    selectionStyle = .none
    backgroundColor = MDCPalette.lightBlue.tint50
    prepareUserImage()
    prepareUserName()
    prepareUserRole()
    prepareAcceptButton()
    prepareDeclineButton()
    prepareInkViewController()
  }
  
  private func prepareUserImage() {
    userImageView = UIImageView()
    userImageView.layer.cornerRadius = 25
    userImageView.clipsToBounds = true
    
    contentView.addSubview(userImageView)
    
    userImageView.snp.makeConstraints { make in
      make.left.equalTo(10)
      make.centerY.equalTo(contentView)
      make.width.equalTo(50)
      make.height.equalTo(50)
    }
    
    userImage
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .map { Nuke.Manager.shared.loadImage(with: $0).asObservable() }
      .flatMap { $0 }
      .observeOn(MainScheduler.instance)
      .bind(to: userImageView.rx.image)
      .disposed(by: disposeBag)
  }
  
  private func prepareUserName() {
    userNameLabel = UILabel()
    
    userNameLabel.font = MDCTypography.subheadFont()
    userNameLabel.textColor = MDCPalette.grey.tint900
    
    contentView.addSubview(userNameLabel)
    
    userNameLabel.snp.makeConstraints { make in
      make.left.equalTo(userImageView).offset(60)
      make.top.equalTo(contentView.snp.top).offset(15)
    }
    
    userName
      .asObservable()
      .bind(to: userNameLabel.rx.text)
      .disposed(by: disposeBag)
    
    //Bind to the Variable recievedName so we can post the Accurate name in MDCAlertController
    userName
      .asObservable()
      .bind(to: receivedName)
      .disposed(by: disposeBag)
  }
  
  private func prepareUserRole() {
    userRoleLabel = UILabel()
    userRoleLabel.font = MDCTypography.body1Font()
    
    contentView.addSubview(userRoleLabel)
    
    userRoleLabel.snp.makeConstraints { make in
      make.left.equalTo(userImageView).offset(60)
      make.bottom.equalTo(contentView.snp.bottom).inset(15)
    }
    
    userRole
      .asObservable()
      .map { $0?.role }
      .bind(to: userRoleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareAcceptButton() {
    acceptButton = UIButton()
    acceptButton.backgroundColor = MDCPalette.green.tint500
    acceptButton.layer.cornerRadius = 20
    acceptButton.clipsToBounds = true
    
    acceptImage = UIImageView()
    acceptImage.image = UIImage(named: Constants.Icon.done)?.withRenderingMode(.alwaysTemplate)
    acceptImage.tintColor = MDCPalette.grey.tint50
    
    contentView.addSubview(acceptButton)
    contentView.addSubview(acceptImage)
    
    acceptButton.snp.makeConstraints { make in
      make.centerY.equalTo(contentView)
      make.width.equalTo(40)
      make.height.equalTo(40)
      make.right.equalTo(contentView).inset(65)
    }
    
    acceptImage.snp.makeConstraints { make in
      make.centerY.equalTo(acceptButton)
      make.centerX.equalTo(acceptButton)
      make.width.equalTo(30)
      make.height.equalTo(30)
    }
  }
  
  private func prepareDeclineButton() {
    declineButton = UIButton()
    declineButton.backgroundColor = MDCPalette.red.tint700
    declineButton.layer.cornerRadius = 20
    declineButton.clipsToBounds = true
    
    declineImage = UIImageView()
    declineImage.image = UIImage(named: Constants.Icon.close)?.withRenderingMode(.alwaysTemplate)
    declineImage.tintColor = MDCPalette.grey.tint50
    
    contentView.addSubview(declineButton)
    contentView.addSubview(declineImage)
    
    declineButton.snp.makeConstraints { make in
      make.centerY.equalTo(contentView)
      make.width.equalTo(40)
      make.height.equalTo(40)
      make.left.equalTo(acceptButton).inset(50)
    }
    
    declineImage.snp.makeConstraints { make in
      make.centerX.equalTo(declineButton)
      make.centerY.equalTo(declineButton)
      make.width.equalTo(30)
      make.height.equalTo(30)
    }
  }
  
  public var acceptButtonTap: Observable<Void> {
    return acceptButton.rx.tap.asObservable()
  }
  
  public var declineButtonTap: Observable<Void> {
    return declineButton.rx.tap.asObservable()
  }

  private func prepareInkViewController() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

// MARK: InkDelegate
extension ReceivedCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    if declineButton.frame.contains(location) || acceptButton.frame.contains(location) {
      return false
    }
    return true
  }
}
