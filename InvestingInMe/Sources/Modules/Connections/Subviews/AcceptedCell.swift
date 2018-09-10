//
//  AcceptedCell.swift
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

public class AcceptedCell: UITableViewCell {
  
  //MARK: InkViewController
  private var inkViewController: MDCInkTouchController!

  //MARK: Publish Subjects
  public let userImage: PublishSubject<URL> = PublishSubject()
  public let userName: PublishSubject<String> = PublishSubject()
  public let userRole: PublishSubject<Role?> = PublishSubject()
  public let message: PublishSubject<String> = PublishSubject()
  public let userId: PublishSubject<Int> = PublishSubject()
  
  // MARK: Variable
  public var receivedId: Variable<Int?> = Variable(nil)
  
  //MARK: Labels
  private var userImageView: UIImageView!
  private var userNameLabel: UILabel!
  private var userRoleLabel: UILabel!
  public var viewProfileButton: UIButton!

  //MARK: Dispose
  // Because we only want the button, it's safe to assume that these other contents may not be re-used for other consumption
  public var dispose: Disposable! {
    didSet {
      disposables.append(dispose)
    }
  }
  
  private var disposables: [Disposable] = []
  
  /// Disposes all from what's given
  private func disposeAll() {
    for dispose in disposables {
      dispose.dispose()
    }
    disposables.removeAll()
  }
  
  private(set) var disposeBag: DisposeBag = DisposeBag()

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
    backgroundColor = MDCPalette.lightGreen.tint50
    prepareUserImage()
    prepareUserName()
    prepareUserRole()
    prepareViewProfileButton()
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

  private func prepareViewProfileButton() {
    viewProfileButton = UIButton()
    viewProfileButton.setTitle("Profile", for: .normal)
    viewProfileButton.titleLabel?.font = MDCTypography.buttonFont()
    
    viewProfileButton.backgroundColor = UIColor.darkBlue
    viewProfileButton.layer.cornerRadius = 2
    viewProfileButton.clipsToBounds = true
    
    contentView.addSubview(viewProfileButton)
    
    viewProfileButton.snp.makeConstraints { make in
      make.height.equalTo(35)
      make.width.equalTo(75)
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
    
    userId
      .asObservable()
      .bind(to: receivedId)
      .disposed(by: disposeBag)
  }
  
  public var viewProfileTap: Observable<Void> {
    return viewProfileButton.rx.tap.asObservable()
  }
  
  private func prepareInkViewController() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

// MARK: InkDelegate
extension AcceptedCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    if viewProfileButton.frame.contains(location) {
      return false
    }
    return true
  }
}
