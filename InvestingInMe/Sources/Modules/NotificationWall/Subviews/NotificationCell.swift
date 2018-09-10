//
//  NotificationCell.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-31.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import MaterialComponents
import RxSwift
import SnapKit
import Nuke
import RxNuke

public final class NotificationCell: UITableViewCell {
  
  //MARK: InkViewController
  private var inkViewController: MDCInkTouchController!
  
  //MARK: Publish Subjects
  public let userImage: PublishSubject<URL> = PublishSubject()
  public let message: PublishSubject<String> = PublishSubject()
  public let date: PublishSubject<Date> = PublishSubject()
  
  //MARK: Labels
  private var userImageView: UIImageView!
  private var messageLabel: UILabel!
  private var dateLabel: UILabel!
  
  //MARK: DisposeBags
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
    prepareUserImage()
    prepareNotificationMessage()
    prepareDate()
    prepareInkViewController()
  }
  
  private func prepareUserImage() {
    userImageView = UIImageView()
    userImageView.layer.cornerRadius = 25
    userImageView.clipsToBounds = true
    
    contentView.addSubview(userImageView)
    
    userImageView.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
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
  
  private func prepareNotificationMessage() {
    messageLabel = UILabel()
    messageLabel.font = MDCTypography.subheadFont()
    messageLabel.textColor = .black
    messageLabel.numberOfLines = 2
    
    contentView.addSubview(messageLabel)
    
    messageLabel.snp.makeConstraints { make in
      make.left.equalTo(userImageView.snp.right).offset(10)
      make.right.equalTo(contentView)
      make.top.equalTo(contentView).offset(25)
    }
    
    message
      .asObservable()
      .bind(to: messageLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareDate() {
    dateLabel = UILabel()
    dateLabel.font = MDCTypography.captionFont()
    
    contentView.addSubview(dateLabel)
    
    dateLabel.snp.makeConstraints { make in
      make.left.equalTo(messageLabel.snp.left)
      make.right.equalTo(contentView)
      make.top.equalTo(messageLabel.snp.bottom)
    }
    
    date
      .asObservable()
      .map { date in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter.string(from: date)
      }
      .bind(to: dateLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkViewController() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.addInkView()
  }
}
