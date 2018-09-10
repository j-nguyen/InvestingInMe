//
//  SearchProjectViewController.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-23.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift

public final class SearchProjectViewController: UIViewController {
  
  private var router: SearchProjectRouter!
  private var viewModel: SearchProjectViewModelProtocol!
  private var appBar = MDCAppBar()
  
  private var emptyFeaturedProjectView: EmptyView!
  private var tableView: UITableView!
  private var searchBar: UISearchBar!
  private var backButton: UIBarButtonItem!
  private var menuButton: UIBarButtonItem!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: SearchProjectViewModelProtocol, router: SearchProjectRouter) {
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
    prepareBackButton()
  }
  
  private func prepareBackButton() {
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
  
  private func prepareEmptyView() {
    emptyFeaturedProjectView = EmptyView(
      imageLiteral: Constants.Icon.assignmentLate,
      title: "No Search Results",
      descriptionText: "No Results Right Now, Check Back Later!"
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
    appBar.headerViewController.headerView.maximumHeight = 140
    
    Observable.just("Search Projects")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    searchBar = UISearchBar()
    searchBar.barTintColor = MDCPalette.red.tint700
    searchBar.backgroundImage = UIImage()
    searchBar.placeholder = "Search by project name..."
    
    searchBar.rx.text
      .orEmpty
      .bind(to: viewModel.searchProjects)
      .disposed(by: disposeBag)
    
    searchBar.rx.searchButtonClicked
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.searchBar.resignFirstResponder()
      })
      .disposed(by: disposeBag)
    
    appBar.headerStackView.bottomBar = searchBar
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.registerCell(AllProjectCell.self)
    
    view.addSubview(tableView)
    
    viewModel.projects
      .asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: String(describing: AllProjectCell.self), cellType: AllProjectCell.self)) { index, project, cell in
        guard let projectIcon = project.assets.first(where: { $0.project_icon }) else { return }
        cell.projectTitle.onNext(project.name)
        cell.projectRole.onNext(project.role.role)
        cell.projectImage.onNext(projectIcon.url)
        cell.projectCategory.onNext(project.category.type)
      }
      .disposed(by: disposeBag)
    
    tableView.snp.makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
    tableView.rx.itemSelected
      .asObservable()
      .map { [weak self] indexPath in return self?.viewModel.projects.value[indexPath.row] }
      .filterNil()
      .subscribe(onNext: { [weak self] project in
        guard let this = self else { return }
        try? this.router.route(from: this, to: SearchProjectRouter.Routes.projectDetail.rawValue, parameters: ["id": project.id])
      })
      .disposed(by: disposeBag)
    
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}



