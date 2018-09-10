//
//  CreateProjectTextViewCell.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-05.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import UIKit
import MaterialComponents
import RxCocoa

public class CreateProjectTextViewCell: UITableViewCell {
  // MARK: PublishSubjects
  public var desc: String = "" {
    didSet {
      textView.text = desc
    }
  }
  
  public var placeholder: String = "" {
    didSet {
      placeholderTextView.text = placeholder
    }
  }
  
  // MARK: Views
  private var placeholderTextView: UITextView!
  private var textView: UITextView!
  
  // conveience operator
  public var textValue: ControlProperty<String?> {
    return textView.rx.text
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
  
  // MARK: Disposables
  public var disposeable: Disposable! {
    didSet {
      disposeables.append(disposeable)
    }
  }
  
  private var disposeables: [Disposable] = []
  
  public func disposeAll() {
    for disposeable in disposeables {
      disposeable.dispose()
    }
    disposeables.removeAll()
  }
  
  private let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareTextView()
    preparePlaceholderTextView()
  }
  
  private func prepareTextView() {
    textView = UITextView()
    textView.font = MDCTypography.body1Font()
    textView.isScrollEnabled = false
    
    contentView.addSubview(textView)
    
    textView.snp.makeConstraints { make in
      make.edges.equalTo(contentView).inset(5)
    }
    
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
