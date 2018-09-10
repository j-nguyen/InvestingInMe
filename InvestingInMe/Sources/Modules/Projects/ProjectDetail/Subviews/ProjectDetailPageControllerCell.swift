//
//  ProjectDetailPageControllerCell.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-13.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialPageControl
import UIKit
import RxSwift
import SnapKit
import MaterialComponents
import RxOptional
import Nuke
import RxNuke

public class ProjectDetailPageControllerCell: UITableViewCell, UIScrollViewDelegate {
  // MARK: Get page
  public let projectAssets = PublishSubject<[Asset]>()
  public let currentPage: Variable<Int> = Variable(0)
  private var index = 0
  
  private var pageControl = MDCPageControl()
  private var scrollView: UIScrollView!

  public let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
  }

  private func prepareView() {
    selectionStyle = .none
    prepareScrollView()
  }
  
  private func prepareScrollView() {
    projectAssets
      .do(onNext: { [weak self] assets in
        guard let this = self else { return }
        this.scrollView.subviews.forEach { $0.removeFromSuperview() }
        this.pageControl.numberOfPages = assets.count
        this.scrollView.contentSize = CGSize(
          width: this.contentView.bounds.width * CGFloat(assets.count),
          height: this.contentView.bounds.height
        )
        this.index = 0
      })
      .flatMap { Observable.from($0) }
      .flatMap { Nuke.Manager.shared.loadImage(with: $0.url).asObservable() }
      .map { image -> UIImageView in
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin]
        return imageView
      }
      .subscribe(onNext: { [weak self] view in
        guard let this = self else { return }
        let pageFrame = this.contentView.bounds.offsetBy(dx: CGFloat(this.index) * this.contentView.bounds.width, dy: 0)
        view.frame = pageFrame
        this.index += 1
        this.currentPage.value = this.pageControl.currentPage
        this.scrollView.addSubview(view)
      })
      .disposed(by: disposeBag)
    
    contentView.backgroundColor = .white
    
    scrollView = UIScrollView()
    scrollView.frame = contentView.frame
    scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    scrollView.delegate = self
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    
    contentView.addSubview(scrollView)
    
    scrollView.isUserInteractionEnabled = false
    contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
    
    pageControl.rx.controlEvent(.valueChanged)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        var offset = this.scrollView.contentOffset
        offset.x = CGFloat(this.pageControl.currentPage) * this.scrollView.bounds.size.width
        this.scrollView.setContentOffset(offset, animated: true)
        this.currentPage.value = this.pageControl.currentPage
      }).disposed(by: disposeBag)
    
    
    pageControl.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
    let pageControlSize = pageControl.sizeThatFits(contentView.bounds.size)
    pageControl.frame = CGRect(x: 0, y: contentView.bounds.height - pageControlSize.height - 10, width: contentView.bounds.width, height: pageControlSize.height)
    
    contentView.addSubview(pageControl)
  }
    
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    pageControl.scrollViewDidScroll(scrollView)
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    pageControl.scrollViewDidEndDecelerating(scrollView)
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    pageControl.scrollViewDidEndScrollingAnimation(scrollView)
  }
  
}
