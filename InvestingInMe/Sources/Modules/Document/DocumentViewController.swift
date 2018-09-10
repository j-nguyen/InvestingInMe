//
//  DocumentViewController.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-04-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import WebKit
import MaterialComponents

public class DocumentViewController: UIViewController {
  // MARK: Properties
  private var viewModel: DocumentViewModelProtocol!
  
  // MARK: Views
  private var webView: WKWebView!
  private var closeButton: UIBarButtonItem!
  private var doneButton: UIBarButtonItem!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: DocumentViewModelProtocol) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = viewModel.title
    setupView()
  }
  
  private func setupView() {
    setupWebView()
    setupButton()
  }
  
  private func setupWebView() {
    webView = WKWebView()
    webView.load(viewModel.urlRequest)
    
    view.addSubview(webView)
    
    webView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
  }
  
  private func setupButton() {
    if viewModel.initial {
      doneButton = UIBarButtonItem(
        title: "Accept",
        style: .plain,
        target: nil,
        action: nil
      )
      navigationItem.rightBarButtonItem = doneButton
      
      doneButton.rx.tap
        .subscribe(onNext: { [weak self] in
          self?.dismiss(animated: true) {
            UserDefaults.standard.set(true, forKey: "tos")
          }
        })
        .disposed(by: disposeBag)
    } else {
      closeButton = UIBarButtonItem(
        image: UIImage(named: Constants.Icon.close)?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: nil,
        action: nil
      )
      navigationItem.leftBarButtonItem = closeButton
      
      closeButton.rx.tap
        .subscribe(onNext: { [weak self] in
          self?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
    }
  }
}
