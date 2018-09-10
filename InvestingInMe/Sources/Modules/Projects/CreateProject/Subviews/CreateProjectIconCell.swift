//
//  CreateProjectIconCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-05.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import MaterialComponents
import Nuke
import RxNuke

public class CreateProjectIconCell: UITableViewCell {
  // MARK: Publish Subjects
  public let title: PublishSubject<String> = PublishSubject()
  public let url: PublishSubject<URL> = PublishSubject()
  public let dataImage: PublishSubject<Data> = PublishSubject()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private var placeholderView: UIImageView!
  private var inkViewController: MDCInkTouchController!
  
  // Dispose
  public var disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    placeholderView.image = nil
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareTitleLabel()
    preparePlaceholderView()
    prepareInkView()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.titleFont()
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func preparePlaceholderView() {
    placeholderView = UIImageView()
    placeholderView.contentMode = .scaleAspectFit
    placeholderView.layer.cornerRadius = 25
    placeholderView.clipsToBounds = true
    
    contentView.addSubview(placeholderView)
    
    placeholderView.snp.makeConstraints { make in
      make.width.equalTo(100)
      make.height.equalTo(100)
      make.center.equalTo(contentView)
    }
    
    let sharedURL = url.asObservable().share()
    
    sharedURL
      .filter { $0.absoluteString != Constants.placeholderImage }
      .flatMap { Nuke.Manager.shared.loadImage(with: $0).asObservable() }
      .map { UIImagePNGRepresentation($0) }
      .filterNil()
      .bind(to: dataImage)
      .disposed(by: disposeBag)
    
    sharedURL
      .asObservable()
      .flatMap { Nuke.Manager.shared.loadImage(with: $0).asObservable() }
      .bind(to: placeholderView.rx.image)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.addInkView()
  }
}
