//
//  SendMessageViewController.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import MaterialComponents

public final class SendMessageViewController: UIViewController {
  
  //MARK: Required Variables
  private var viewModel: SendMessageViewModelProtocol!
  
  //MARK: AppBar Properties
  private let appBar: MDCAppBar = MDCAppBar()
  private var closeButton: UIBarButtonItem!
  private var sendButton: UIBarButtonItem!
  
  //MARK: TableView
  private var tableView: UITableView!
  
  //MARK: DataSource
  fileprivate var dataSource: RxTableViewSectionedReloadDataSource<SendMessageViewModel.Section>!
  
  //MARK: Dispose
  private let disposeBag: DisposeBag = DisposeBag()
  
  //MARK: Initializers
  public convenience init(viewModel: SendMessageViewModel) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    
    //Add the AppBar header to this ViewController
    addChildViewController(appBar.headerViewController)
  }
  
  //Override initializer
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return appBar.headerViewController
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNeedsStatusBarAppearanceUpdate()
  
    //Set the NavBar to hidden state so we can give a custom appearance to this ViewController
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    //Prepare the View
    prepareView()
  }
  
  //Mark: PrepareView
  private func prepareView() {
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationCloseButton()
    prepareNavigationSendButton()
    appBar.addSubviewsToParent()
  }
  
  private func prepareNavigationBar() {
    
    //Set NavigationBar Style
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    //Setup scroll tracking
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    //Bind title to NavBar
    Observable.just("Send Message")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    //Observe NavBar
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationCloseButton() {
    
    //Set the close button properties and method calls
    closeButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.close)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    closeButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = closeButton
  }

  
  private func prepareNavigationSendButton() {
    sendButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.send)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    viewModel.sendButtonTap = sendButton.rx.tap.asObservable()

    viewModel.sendButtonSuccess
      .asObservable()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        let message = MDCSnackbarMessage(text: "Request Sent!")
        this.dismiss(animated: true, completion: {
          MDCSnackbarManager.show(message)
        })
      })
      .disposed(by: disposeBag)
    
    viewModel.sendButtonFail
      .asObservable()
      .subscribe(onNext: { response in
        let message = MDCSnackbarMessage(text: response.reason)
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.bindButtons()
    
    navigationItem.rightBarButtonItem = sendButton
  }
  
  private func prepareTableView() {
    
    //Declare the TableView and it's properties
    tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.contentInsetAdjustmentBehavior = .never
    
    //Set the TableView Delegate
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    
    //Registed the TableView Cells
    tableView.registerCell(SendMessageNameCell.self)
    tableView.registerCell(SendMessageCell.self)
    
    //Add the TableView to the View
    view.addSubview(tableView)
    
    //Set Layout of TableView
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }

    dataSource = RxTableViewSectionedReloadDataSource(
      configureCell: { [weak self] dataSource, tableView, index, model in
        guard let this = self else { return UITableViewCell() }

        switch dataSource[index] {
          case let .recipient(_, _, name):
            let cell = tableView.dequeueCell(ofType: SendMessageNameCell.self, for: index)
            cell.userName.on(.next(name))
            
            return cell
          case let .message(_, message):
              let cell = tableView.dequeueCell(ofType: SendMessageCell.self, for: index)
            cell.message.on(.next(message))
              
              cell.textValue
                .orEmpty
                .map { text -> String in
                  if text == "Enter a message..." {
                    return ""
                  }
                  return text
                }
                .map { $0.encode }
                .filterNil()
                .bind(to: this.viewModel.message)
                .disposed(by: cell.disposeBag)
          
          return cell
        }
    })
    
    viewModel.section
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}

extension SendMessageViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
      case .message:
        return 200
      case .recipient:
        return 60
    }
  }
}
