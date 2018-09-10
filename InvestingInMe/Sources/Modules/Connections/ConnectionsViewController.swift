//
//  ConnectionsViewController.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-20.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import MaterialComponents
import MessageUI

public class ConnectionsViewController: UIViewController, MFMailComposeViewControllerDelegate {
  
  //UIView
  private var viewModel: ConnectionsViewModelProtocol!
  private var router: ConnectionsRouter!
  
  //AppBar
  private var menuButton: UIBarButtonItem!
  private var editButton: UIBarButtonItem!
  private var backButton: UIBarButtonItem!
  private var appBar = MDCAppBar()
  
  //TableView
  private var tableView: UITableView!
  
  //Views
  private var emptyConnectionView: EmptyView!
  private var loadingIcon: MaterialLoader!
  
  //DataSource
  private var dataSource: RxTableViewSectionedReloadDataSource<ConnectionsViewModel.Section>!
  
  private let disposeBag = DisposeBag()
  private var refreshControl: UIRefreshControl!
  
  public convenience init(viewModel: ConnectionsViewModel, router: ConnectionsRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
    
    addChildViewController(appBar.headerViewController)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
    
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  private func prepareView() {
    prepareRefreshControl()
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationButton()
    prepareEmptyReceivedView()
    prepareMaterialLoader()
    appBar.addSubviewsToParent()
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Connections")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationButton() {
    // checks if it's in stack
    menuButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.menu)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    menuButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        
        this.drawerViewController?.open()
      })
      .disposed(by: disposeBag)
    
    if (drawerViewController?.isViewControllerInNavStack(self) ?? false) {
      backButton = UIBarButtonItem(
        image: UIImage(named: Constants.Icon.backArrow)?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: nil,
        action: nil
      )
      
      backButton.rx.tap
        .asObservable()
        .subscribe(onNext: { [weak self] in
          self?.drawerViewController?.popViewController(animated: true)
        })
        .disposed(by: disposeBag)
      
      navigationItem.leftBarButtonItems = [backButton, menuButton]
    } else {
      navigationItem.leftBarButtonItem = menuButton
    }
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.refreshControl = refreshControl
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.rowHeight = 70
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(SentCell.self)
    tableView.registerCell(ReceivedCell.self)
    tableView.registerCell(AcceptedCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedReloadDataSource<ConnectionsViewModel.Section>(
      configureCell: { [weak self] (dataSource, table, index, model) in
        guard let this = self else { return UITableViewCell()}
        switch model {
        case let .receivedConnections(_, userImage, userName, userRole, _, _):
          let cell = table.dequeueCell(ofType: ReceivedCell.self, for: index)
          cell.userImage.on(.next(userImage))
          cell.userName.on(.next(userName))
          cell.userRole.on(.next(userRole))
          
          cell.dispose = cell.declineButtonTap
            .subscribe(onNext: { [weak cell] in
              guard let cell = cell else { return }
              let alertController = MDCAlertController(title: "Are You Sure?", message: "Press Decline to decline this request from \(String(describing: cell.receivedName.value!))?")
              let confirm = MDCAlertAction(title: "Decline") {(action) in this.viewModel.declineConnection.on(.next(index)) }
              alertController.addAction(confirm)
              alertController.addAction(MDCAlertAction(title: "Cancel"))
              this.present(alertController, animated: true, completion: nil)
            })
          
          cell.dispose = cell.acceptButtonTap
            .subscribe(onNext: { [weak cell] in
              guard let cell = cell else { return }
              let alertController = MDCAlertController(title: "Accept Request", message: "Press Accept to accept this request from \(String(describing: cell.receivedName.value!))")
              let confirm = MDCAlertAction(title: "Accept") {(action) in this.viewModel.acceptConnection.on(.next(index)) }
              alertController.addAction(confirm)
              alertController.addAction(MDCAlertAction(title: "Cancel"))
              this.present(alertController, animated: true, completion: nil)
            })
          
          return cell
        case let .acceptedConnections(_, userImage, userName, userRole, _, _, userId, _):
          let cell = table.dequeueCell(ofType: AcceptedCell.self, for: index)
          cell.userImage.on(.next(userImage))
          cell.userName.on(.next(userName))
          cell.userRole.on(.next(userRole))
          cell.userId.on(.next(userId))
          
          cell.dispose = cell.viewProfileTap
            .subscribe(onNext: { [weak cell] in
              guard let cell = cell else { return }
              try? this.router.route(from: this, to: ConnectionsRouter.Routes.connectionProfile.rawValue, parameters: ["userId": cell.receivedId.value!])
            })
          
          return cell
        case let .sentConnections(_, userImage, userName, userRole, _, _):
          let cell = table.dequeueCell(ofType: SentCell.self , for: index)
          cell.userImage.on(.next(userImage))
          cell.userName.on(.next(userName))
          cell.userRole.on(.next(userRole))

          cell.dispose = cell.cancelRequestTap
            .subscribe(onNext: { _ in
              let alertController = MDCAlertController(title: "Are You Sure?", message: "Press Yes to cancel your request to \(userName)?")
              let confirm = MDCAlertAction(title: "Yes") {(action) in this.viewModel.declineConnection.on(.next(index)) }
              alertController.addAction(confirm)
              alertController.addAction(MDCAlertAction(title: "No"))
              this.present(alertController, animated: true, completion: nil)
            })
          
          return cell
        }
      })
    
    dataSource.canEditRowAtIndexPath = { _, _ in
      return true
    }
    
    //Bind the viewModel Section to the tableView items datasource
    viewModel.connections
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.declineConnectionSuccess
      .subscribe(onNext: {
        let snackbarMessage = MDCSnackbarMessage(text: "Connection has been Deleted!")
        MDCSnackbarManager.show(snackbarMessage)
      })
      .disposed(by: disposeBag)
    
    viewModel.acceptConnectionSuccess
      .subscribe(onNext: { _ in
        let snackbarMessage = MDCSnackbarMessage(text: "Connection has been Accepted!")
        MDCSnackbarManager.show(snackbarMessage)
      })
      .disposed(by: disposeBag)
    
    viewModel.itemSelected = tableView.rx.itemSelected.asObservable()
    viewModel.bindButtons()
    
    viewModel.acceptedConnection
      .subscribe(onNext: { [weak self] content in
        guard let this = self else { return }
        
        // Create our actions here
        let alertController = ModuleFactoryAssembler.makeCustomDialog(title: content.title, message: content.message)
        
        //Declare the dismiss action
        let cancel = MDCAlertAction(title: "Close")
        alertController.addAction(cancel)
        
        //Declare the call action
        if content.phone != "No Phone Number" {
          let call = MDCAlertAction(title: "Call") { _ in
            let url: NSURL = URL(string: "TEL://\(content.phone)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
          }
          alertController.addAction(call)
        }
        
        //Declare the email action
        if content.email != "No Email Address" {
          let email = MDCAlertAction(title: "Email") { _ in
            if MFMailComposeViewController.canSendMail() {
              let emailController = MFMailComposeViewController()
              emailController.mailComposeDelegate = this
              emailController.setToRecipients(["\(content.email)"])
              emailController.setSubject("InvestingInMe Project")
              emailController.setMessageBody("<p>Hi, I saw a project on investinginme I'd like to talk to you about.</p>", isHTML: true)
              this.present(emailController, animated: true, completion: nil)
            } else {
              ModuleFactoryAssembler.makeSnackbarMessage(message: "Mail services are currently unavailable on your device.")
            }
          }
          alertController.addAction(email)
        }
        
        this.present(alertController, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.receivedConnection
      .subscribe(onNext: { [weak self] message in
        guard let this = self else { return }
        this.present(
          ModuleFactoryAssembler.makeMessageDialog(message: message),
          animated: true,
          completion: nil
        )
      })
      .disposed(by: disposeBag)
    
    viewModel.sentConnection
      .subscribe(onNext: { [weak self] message in
        guard let this = self else { return }
        this.present(
          ModuleFactoryAssembler.makeMessageDialog(message: message),
          animated: true,
          completion: nil
        )
      })
      .disposed(by: disposeBag)
  }
  
  public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
  
  private func prepareEmptyReceivedView() {
    emptyConnectionView = EmptyView(
      imageLiteral: Constants.Icon.mailbox,
      title: "No Connections",
      descriptionText: "You Don't Have Any Connections Currently!"
    )
    emptyConnectionView.isHidden = true
    
    view.addSubview(emptyConnectionView)
    
    emptyConnectionView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.isConnectionsEmpty
      .asObservable()
      .map { !$0 }
      .subscribe(onNext: { [weak self] empty in
        self?.emptyConnectionView.isHidden = empty
        self?.tableView.separatorStyle = empty ? .singleLine : .none
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareRefreshControl() {
    refreshControl = UIRefreshControl()
    
    refreshControl.rx.controlEvent(.valueChanged)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.viewModel.refreshContent.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    viewModel.refreshSuccess
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.refreshControl.endRefreshing()
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareMaterialLoader() {
    loadingIcon = MaterialLoader()
    loadingIcon.startLoad()
    
    view.addSubview(loadingIcon)
    
    loadingIcon.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.loadingComplete
      .subscribe(onNext: { [weak self] in
        self?.loadingIcon.endLoad()
      }).disposed(by: disposeBag)
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

// MARK:  TableViewDelegate
extension ConnectionsViewController: UITableViewDelegate {
  
  //Set header styling
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label: UILabel = UILabel()
    label.font = MDCTypography.subheadFont()
    label.textColor = MDCPalette.grey.tint800
    label.backgroundColor = dataSource[section].backgroundColor
    label.text = "  \(dataSource[section].title)"
    
    return label
  }

  //Set header height
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let deleteConnection = UITableViewRowAction(
      style: .normal,
      title: "Delete Connection",
      handler: { [weak self] _, index in
        guard let this = self else { return }
        let alertController = MDCAlertController(title: "Delete Connection", message: "Are you sure you want to delete this Connection?")
        let cancelAction = MDCAlertAction(title: "Cancel")
        let confirmAction = MDCAlertAction(title: "Confirm") { _ in
          this.viewModel.declineConnection.on(.next(indexPath))
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        this.present(alertController, animated: true, completion: nil)
      }
    )
    deleteConnection.backgroundColor = MDCPalette.red.tint600
    return [deleteConnection]
  }
}
