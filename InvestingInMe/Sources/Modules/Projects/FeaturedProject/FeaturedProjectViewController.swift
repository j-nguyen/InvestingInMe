//
//  HomeViewController.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift

public final class FeaturedProjectViewController: UIViewController {
  // MARK: Properties
  private var router: FeaturedProjectRouter!
  private var viewModel: FeaturedProjectViewModelProtocol!
  
  // MARK: Views
  private var menuButton: UIBarButtonItem!
  private var tableView: UITableView!
  private var emptyFeaturedProjectView: EmptyView!
  private var loadingIcon: MaterialLoader!
  private var appBar = MDCAppBar()
  private var floatingButton: MDCFloatingButton!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: FeaturedProjectViewModel, router: FeaturedProjectRouter) {
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
    prepareTerm()
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationAddButton()
    prepareEmptyView()
    prepareMaterialLoader()
  }
  
  private func prepareTerm() {
    if UserDefaults.standard.bool(forKey: "tos") == false {
      let url = URL(string: Constants.TERMS_OF_SERVICE_URL)!
      let documentViewController = DocumentAssembler.make(title: "Terms of Service", url: url, initial: true)
      self.present(documentViewController, animated: true)
    }
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Featured Projects")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationAddButton() {
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
    
    navigationItem.leftBarButtonItem = menuButton
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.rowHeight = 150
    tableView.registerCell(FeaturedProjectCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
    
    viewModel.items.asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: String(describing: FeaturedProjectCell.self), cellType: FeaturedProjectCell.self)) { indexPath, model, cell in
        cell.projectTitle.onNext(model.title)
        cell.projectDescription.onNext(model.description)
        cell.projectImage.onNext(model.image)
        cell.projectCategory.onNext(model.category)
        cell.projectRole.onNext(model.role)
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .asObservable()
      .map { [weak self] indexPath in return self?.viewModel.items.value[indexPath.row] }
      .filterNil()
      .subscribe(onNext: { [weak self] project in
        guard let this = self else { return }
        try? this.router.route(from: this, to: FeaturedProjectRouter.Routes.projectDetail.rawValue, parameters: ["id": project.id])
      })
      .disposed(by: disposeBag)
    
  }
  
  private func prepareFloatingActionButton() {
    floatingButton = MDCFloatingButton()
    floatingButton.setTitle("+", for: .normal)
    floatingButton.sizeToFit()
    floatingButton.backgroundColor = MDCPalette.red.tint700
    
    floatingButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(from: this, to: FeaturedProjectRouter.Routes.createProject.rawValue)
      })
      .disposed(by: disposeBag)
    
    floatingButton.snp.makeConstraints { make in
      make.right.equalTo(view).inset(20)
      make.bottom.equalTo(view).inset(20)
    }
  }
  
  private func prepareEmptyView() {
    emptyFeaturedProjectView = EmptyView(
      imageLiteral: Constants.Icon.assignmentLate,
      title: "No Featured Projects",
      descriptionText: "No Projects Right Now, Check Back Later!"
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



