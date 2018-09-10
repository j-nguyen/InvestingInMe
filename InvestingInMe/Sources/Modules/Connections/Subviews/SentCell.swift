//
//  SentCell.swift
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

public final class SentCell: UITableViewCell {
  
  //MARK: InkViewController
  private var inkViewController: MDCInkTouchController!
  
  //MARK: Publish Subjects
  public var userImage: PublishSubject<URL> = PublishSubject()
  public var userName: PublishSubject<String> = PublishSubject()
  public var userRole: PublishSubject<Role?> = PublishSubject()
  
  //MARK: Labels
  private var userImageView: UIImageView!
  private var userNameLabel: UILabel!
  private var userRoleLabel: UILabel!
  public var cancelButton: UIButton!
  
  //MARK: Dispose
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

  //MARK: PrepareView
  private func prepareView() {
    selectionStyle = .none
    backgroundColor = MDCPalette.red.tint50
    prepareUserImage()
    prepareUserName()
    prepareUserRole()
    prepareCancelButton()
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
    
    //Set the image to the image view of the cell
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
    
    //Set the user name to the cells name field
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
  
  
  private func prepareCancelButton() {
    cancelButton = UIButton()
    cancelButton.setTitle("Cancel", for: .normal)
    cancelButton.titleLabel?.font = MDCTypography.buttonFont()
    
    cancelButton.backgroundColor = MDCPalette.red.tint700
    cancelButton.layer.cornerRadius = 2
    cancelButton.clipsToBounds = true
    
    contentView.addSubview(cancelButton)
    
    cancelButton.snp.makeConstraints { make in
      make.height.equalTo(35)
      make.width.equalTo(75)
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
  }
  
  public var cancelRequestTap: Observable<Void> {
    return cancelButton.rx.tap.asObservable()
  }
  
  private func prepareInkViewController() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

// MARK: InkDelegate
extension SentCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    if cancelButton.frame.contains(location) {
      return false
    }
    return true
  }
}
