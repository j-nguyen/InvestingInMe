//
//  AllProjectViewController.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-22.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift
import RxCocoa

public final class AllProjectViewController: UIViewController {
  // MARK: Properties
  private var router: AllProjectRouter!
  private var viewModel: AllProjectViewModelProtocol!
  
  // MARK: Views
  private var menuButton: UIBarButtonItem!
  private var sortButton: UIBarButtonItem!
  private var searchButton: UIBarButtonItem!
  private var floatingButton: MDCFloatingButton!
  private var appBar = MDCAppBar()
  private var refreshControl: UIRefreshControl!
  private var loadingIcon: MaterialLoader!
  
  private var tableView: UITableView!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: AllProjectViewModel, router: AllProjectRouter) {
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
    prepareFloatingButton()
    prepareNavigationBar()
    prepareNavigationButtons()
    prepareMaterialLoader()
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("All Projects")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationButtons() {
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
    
    searchButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.search)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    searchButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(from: this, to: AllProjectRouter.Routes.searchProjects.rawValue, parameters: nil)
      })
      .disposed(by: disposeBag)
    
    sortButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.sort)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )

    sortButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(from: this, to: AllProjectRouter.Routes.filterProjects.rawValue, parameters: nil)
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = menuButton
    navigationItem.rightBarButtonItems =  [sortButton, searchButton]
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.refreshControl = refreshControl
    tableView.registerCell(AllProjectCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
    viewModel.items.asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: String(describing: AllProjectCell.self), cellType: AllProjectCell.self)) { (tableView, element, cell) in
        cell.projectTitle.onNext(element.title)
        cell.projectCategory.onNext(element.category)
        cell.projectRole.onNext(element.role)
        cell.projectImage.onNext(element.image)
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .asObservable()
      .map{ [weak self] indexPath in return self?.viewModel.items.value[indexPath.row] }
      .filterNil()
      .subscribe(onNext: { [weak self] project in
        guard let this = self else { return }
        try? this.router.route(from: this, to: FeaturedProjectRouter.Routes.projectDetail.rawValue, parameters: ["id": project.id])
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
  
  private func prepareFloatingButton() {
    floatingButton = MDCFloatingButton()
    floatingButton.setTitle("+", for: .normal)
    floatingButton.sizeToFit()
    floatingButton.backgroundColor = MDCPalette.red.tint700
    
    view.addSubview(floatingButton)
    
    floatingButton.snp.makeConstraints { make in
      make.right.equalTo(view).inset(20)
      make.bottom.equalTo(view).inset(20)
    }
    
    floatingButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(from: this, to: AllProjectRouter.Routes.createProject.rawValue)
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
      })
      .disposed(by: disposeBag)
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}
