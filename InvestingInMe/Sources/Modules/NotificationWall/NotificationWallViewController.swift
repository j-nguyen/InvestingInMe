//
//  NotificationWallViewController.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-31.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift

public final class NotificationWallViewController: UIViewController {
  
  private var router: NotificationWallRouter!
  private var viewModel: NotificationWallViewModelProtocol!
  private var appBar = MDCAppBar()
  
  private var emptyFeaturedProjectView: EmptyView!
  private var refreshControl: UIRefreshControl!
  private var tableView: UITableView!
  private var menuButton: UIBarButtonItem!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: NotificationWallViewModelProtocol, router: NotificationWallRouter) {
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
    appBar.addSubviewsToParent()
  }
  
  private func prepareView() {
    prepareRefreshControl()
    prepareTableView()
    prepareEmptyView()
    prepareNavigationBar()
    prepareBackButton()
  }
  
  private func prepareBackButton() {

    menuButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.menu)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    menuButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        self?.drawerViewController?.open()
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItems = [menuButton]
  }
  
  private func prepareEmptyView() {
    emptyFeaturedProjectView = EmptyView(
      imageLiteral: Constants.Icon.assignmentLate,
      title: "No Notifications",
      descriptionText: "You currently have no notifications, check back later!"
    )
    emptyFeaturedProjectView.isHidden = true
    
    view.addSubview(emptyFeaturedProjectView)
    
    emptyFeaturedProjectView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.isItemsEmpty
      .map { !$0 }
      .subscribe(onNext: { [weak self] isEmpty in
        self?.emptyFeaturedProjectView.isHidden = isEmpty
        self?.tableView.separatorStyle = isEmpty ? .singleLine : .none
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    appBar.navigationBar.observe(navigationItem)
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Notifications")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.refreshControl = refreshControl
    tableView.rowHeight = 100
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.registerCell(NotificationCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
    viewModel.notifications
      .asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: String(describing: NotificationCell.self), cellType: NotificationCell.self)) { index, notification, cell in
        cell.userImage.onNext(notification.user.picture)
        cell.message.onNext(notification.message)
        cell.date.onNext(notification.created_at)
      }
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(Notification.self)
      .asObservable()
      .subscribe(onNext: { [weak self] notification in
        guard let this = self, let notificationType = NotificationType(rawValue: notification.type) else { return }
        // Determine which router we're going to
        switch notificationType {
        case .connection:
          try? this.router.route(
            from: this,
            to: NotificationWallRouter.Routes.connections.rawValue,
            parameters: nil
          )
        case .featuredProject:
          break
        case .project:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareRefreshControl() {
    refreshControl = UIRefreshControl()
    
    refreshControl.rx.controlEvent(.valueChanged)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.viewModel.onRefresh.onNext(())
      })
      .disposed(by: disposeBag)
    
    viewModel.onRefreshSuccess
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.refreshControl.endRefreshing()
      })
      .disposed(by: disposeBag)
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}
