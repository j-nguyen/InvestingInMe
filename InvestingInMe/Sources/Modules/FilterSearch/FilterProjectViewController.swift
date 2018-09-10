//
//  FilterViewController.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift
import RxDataSources

public final class FilterProjectViewController: UIViewController {
  private var viewModel: FilterProjectViewModelProtocol!
  private var router: FilterProjectRouter!
  
  private var dataSource: RxTableViewSectionedReloadDataSource<FilterProjectViewModel.Section>!
  private var menuButton: UIBarButtonItem!
  private var saveButton: UIBarButtonItem!
  private var backButton: UIBarButtonItem!
  private var appBar = MDCAppBar()
  
  private var tableView: UITableView!
  private var tableViewCell: UITableViewCell!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: FilterProjectViewModel, router: FilterProjectRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
    addChildViewController(appBar.headerViewController)
    
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
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
    prepareTableView()
    prepareNavigationBar()
    prepareBackItems()
  }
  
  private func prepareBackItems() {
    backButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.backArrow)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    backButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.drawerViewController?.popViewController(animated: true)
      }).disposed(by: disposeBag)
    
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
    
    navigationItem.leftBarButtonItems = [backButton, menuButton]
  }
  
  private func prepareNavigationBar() {
    
    saveButton = UIBarButtonItem(
      title: "Done",
      style: .plain,
      target: nil,
      action: nil
    )
    
    viewModel.isEnabled
      .bind(to: saveButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    saveButton.rx.tap.asObservable()
      .subscribe(onNext: {  [weak self] _  in
        guard let this = self else { return }
        try? this.router.route(
          from: this, to: FilterProjectRouter.Routes.filteredProjects.rawValue,
          parameters:  [
            "categories": this.viewModel.categoryQueries.value,
            "roles": this.viewModel.roleQueries.value
          ]
        )
      }).disposed(by: disposeBag)
    
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
  
    Observable.just("Filter")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
     navigationItem.rightBarButtonItem = saveButton
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.registerCell(FilterProjectCell.self)
    self.view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedReloadDataSource<FilterProjectViewModel.Section>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
      let cell = tableView.dequeueCell(ofType: FilterProjectCell.self, for: indexPath)
      switch item {
      case let .category(_, label,  _, checked):
        cell.name.onNext(label)
        cell.projectImage.onNext(checked)
        return cell
      case let .role(_, label,  _, checked):
        cell.name.onNext(label)
        cell.projectImage.onNext(checked)
        return cell
      }
    })
    
    dataSource.titleForHeaderInSection = { dataSource, index in
      return dataSource[index].title
    }
    
    viewModel.items.asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.itemSelected = tableView.rx.itemSelected.asObservable()
    
    viewModel.bindButtons()
  }
  
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}


