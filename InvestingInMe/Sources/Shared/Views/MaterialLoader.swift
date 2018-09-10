//
//  MaterialLoader.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-23.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents
import SnapKit
import RxSwift
import RxCocoa

public class MaterialLoader: UIView {
  // MARK: Properties
  public var activityType: MDCActivityIndicatorMode = .indeterminate {
    didSet {
      activityIndicator.indicatorMode = activityType
    }
  }
  
  // MARK: Convenience operators
  public var progress: Binder<Float> {
    return activityIndicator.rx.progress
  }
  
  // MARK: Views
  private var activityIndicator: MDCActivityIndicator!
  private var testView: UIView!
  private var loadingText: UILabel!
  
  public convenience init() {
    self.init(frame: .zero)
    prepareView()
  }
  
  convenience init(frame: CGRect, message: String) {
    self.init(frame: frame)
    prepareView()
    if message.isNotEmpty {
      prepareText(message: message)
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  /// prepare the view
  private func prepareView() {
    backgroundColor = .white
    prepareActivityIndicator()
  }
  
  /// Prepares the activity indicator
  private func prepareActivityIndicator() {
    activityIndicator = MDCActivityIndicator()
    activityIndicator.cycleColors = [MDCPalette.red.tint700, MDCPalette.blue.tint700]
    activityIndicator.indicatorMode = activityType
    activityIndicator.radius = 45
    addSubview(activityIndicator)
    
    activityIndicator.snp.makeConstraints { make in
      make.center.equalTo(self)
    }
  }
  
  private func prepareText(message: String) {
    loadingText = UILabel()
    loadingText.text = message
    loadingText.textColor = MDCPalette.grey.tint800
    loadingText.font = MDCTypography.titleFont()
    
    addSubview(loadingText)
    
    loadingText.snp.makeConstraints { make in
      make.top.equalTo(activityIndicator.snp.bottom).offset(20)
      make.centerX.equalTo(activityIndicator.snp.centerX)
    }
  }
  
  /// Starts the animation
  public func startLoad() {
    activityIndicator.startAnimating()
  }
  
  /// Stops the animation and hides the loading view
  public func endLoad() {
    activityIndicator.stopAnimating()
    isHidden = true
  }
}

