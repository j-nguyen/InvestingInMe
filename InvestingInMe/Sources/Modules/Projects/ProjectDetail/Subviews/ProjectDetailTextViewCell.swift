//
//  ProjectDetailNeedsCell
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-04.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents
import RxOptional

public class ProjectDetailTextViewCell: UITableViewCell {
  // MARK: Properties
  public let value = PublishSubject<String>()
  
  // MARK: Views
  private var textView: UITextView!
  
  private(set) var disposeBag = DisposeBag()
  
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
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  private func prepareTextView() {
    textView = UITextView()
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.font = MDCTypography.body1Font()
    
    contentView.addSubview(textView)
    
    textView.snp.makeConstraints { make in
      make.edges.equalTo(contentView).inset(5)
    }
    
    value.asObservable()
      .map { $0.decode }
      .filterNil()
      .bind(to: textView.rx.text)
      .disposed(by: disposeBag)
  }
}


