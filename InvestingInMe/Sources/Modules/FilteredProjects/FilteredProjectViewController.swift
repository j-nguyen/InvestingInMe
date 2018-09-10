//
//  FilteredProjectViewController.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-05.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift

public final class FilteredProjectViewController: UIViewController {
  
  private var emptyFeaturedProjectView: EmptyView!
  private var router: FilteredProjectRouter!
  private var viewModel: FilteredProjectViewModelProtocol!
  private var backButton: UIBarButtonItem!
  private var menuButton: UIBarButtonItem!
  private var appBar = MDCAppBar()
  
  private var tableView: UITableView!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: FilteredProjectViewModel, router: FilteredProjectRouter) {
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
    prepareTableView()
    prepareEmptyView()
    prepareNavigationBar()
    prepareNavigationButtons()
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Filtered Projects")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareEmptyView() {
    emptyFeaturedProjectView = EmptyView(
      imageLiteral: Constants.Icon.assignmentLate,
      title: "No Filter Results",
      descriptionText: "Please change filter options or check back later!"
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
  
  private func prepareNavigationButtons() {
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
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.contentInsetAdjustmentBehavior = .never
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
        try? this.router.route(from: this, to: FilteredProjectRouter.Routes.projectDetail.rawValue, parameters: ["id": project.id])
      })
      .disposed(by: disposeBag)
    
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

