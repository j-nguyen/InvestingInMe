//
//  CreateProjectScreenshotCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import MaterialComponents

public class CreateProjectScreenshotCell: UITableViewCell {
  // MARK: PublishSubjects
  public let assets: PublishSubject<[UIImage]> = PublishSubject()
  public let dataImage: PublishSubject<[Data]> = PublishSubject()
  
  // MARK: Views
  private var pageControl: MDCPageControl!
  private var scrollView: UIScrollView!
  private var index: Int = 0
  
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
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareScrollView()
    preparePageControl()
  }
  
  private func preparePageControl() {
    pageControl = MDCPageControl()
    pageControl.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
    let pageControlSize = pageControl.sizeThatFits(contentView.bounds.size)
    pageControl.frame = CGRect(x: 0, y: contentView.bounds.height - pageControlSize.height, width: contentView.bounds.width, height: pageControlSize.height)
    
    contentView.addSubview(pageControl)
    
    pageControl.rx.controlEvent(.valueChanged)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        var offset = this.scrollView.contentOffset
        offset.x = CGFloat(this.pageControl.currentPage) * this.scrollView.bounds.size.width
        this.scrollView.setContentOffset(offset, animated: false)
      }).disposed(by: disposeBag)
  }
  
  private func prepareScrollView() {
    scrollView = UIScrollView()
    scrollView.frame = contentView.frame
    scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    scrollView.delegate = self
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isUserInteractionEnabled = false
    
    contentView.addSubview(scrollView)
    contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
    
    assets
      .asObservable()
      .do(onNext: { [weak self] assets in
        guard let this = self else { return }
        this.scrollView.subviews.forEach { $0.removeFromSuperview() }
        // set up the base
        let dataImages: [Data] = assets.map { UIImagePNGRepresentation($0) }.flatMap { $0 }
        this.dataImage.onNext(dataImages)
        // set up page
        this.pageControl.numberOfPages = assets.count
        this.scrollView.contentSize = CGSize(
          width: this.contentView.bounds.width * CGFloat(assets.count),
          height: this.contentView.bounds.height
        )
        this.index = 0
      })
      .flatMap { Observable.from($0) }
      .map { image -> UIImageView in
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin]
        return imageView
      }
      .subscribe(onNext: { [weak self] view in
        guard let this = self else { return }
        let pageFrame = this.contentView.bounds.offsetBy(dx: CGFloat(this.index) * this.contentView.bounds.width, dy: 0)
        view.frame = pageFrame
        this.scrollView.addSubview(view)
        this.index += 1
      })
      .disposed(by: disposeBag)
  }
}

extension CreateProjectScreenshotCell: UIScrollViewDelegate {
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
