//
//  EditProfileDescriptionCell.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-13.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import SnapKit
import MaterialComponents

public final class EditProfileTextViewCell: UITableViewCell {
  // MARK: PublishSubjects
  public let textValue = PublishSubject<String>()
  
  public var placeholder: String = "" {
    didSet {
      placeholderTextView.text = placeholder
    }
  }
  
  // MARK: Views
  private var placeholderTextView: UITextView!
  private var textView: UITextView!
  
  // conveience operator
  public var textControl: Observable<String> {
    return textView.rx.text.orEmpty
      .asObservable()
  }
  
  public var didChange: ControlEvent<Void> {
    return textView.rx.didChange
  }
  
  public var didBeginEditing: ControlEvent<Void> {
    return textView.rx.didBeginEditing
  }
  
  public var didEndEditing: ControlEvent<Void> {
    return textView.rx.didEndEditing
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
    disposeBag = DisposeBag()
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareTextView()
    preparePlaceholderTextView()
  }
  
  private func prepareTextView() {
    textView = UITextView()
    textView.isScrollEnabled = false
    textView.font = MDCTypography.body1Font()
    
    contentView.addSubview(textView)
    
    textView.snp.makeConstraints { make in
      make.edges.equalTo(contentView).inset(5)
    }
    
    textValue
      .asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: textView.rx.text)
      .disposed(by: disposeBag)
    
    textView.rx.didEndEditing
      .asObservable()
      .filter { [weak self] in return self?.textView.text.isEmpty ?? false }
      .subscribe(onNext: { [weak self] in
        self?.placeholderTextView.text = self?.placeholder
      })
      .disposed(by: disposeBag)
  }
  
  private func preparePlaceholderTextView() {
    placeholderTextView = UITextView()
    placeholderTextView.font = MDCTypography.body1Font()
    placeholderTextView.textColor = .lightGray
    placeholderTextView.isScrollEnabled = false
    
    contentView.addSubview(placeholderTextView)
    
    placeholderTextView.snp.makeConstraints { make in
      make.edges.equalTo(contentView).inset(5)
    }

    textView.rx.text.orEmpty
      .asObservable()
      .map { !$0.isEmpty }
      .bind(to: placeholderTextView.rx.isHidden)
      .disposed(by: disposeBag)

    placeholderTextView.rx.didBeginEditing
      .asObservable()
      .subscribe(onNext: { [weak self] in
        self?.textView.becomeFirstResponder()
        self?.placeholderTextView.text = ""
      })
      .disposed(by: disposeBag)
  }
}
