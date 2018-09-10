//
//  UserProjectViewController.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
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

public final class UserProjectViewController: UIViewController {
  // MARK: Properties
  private var viewModel: UserProjectViewModelProtocol!
  private var router: UserProjectRouter!
  
  // MARK: Views
  private var menuButton: UIBarButtonItem!
  private var appBar = MDCAppBar()
  private var floatingButton = MDCFloatingButton()
  private var emptyUserProjectView: EmptyView!
  private var loadingIcon: MaterialLoader!
  private var refreshControl: UIRefreshControl!
  private var tableView: UITableView!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: UserProjectViewModel, router: UserProjectRouter) {
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
    prepareNavigationAddButton()
    prepareEmptyView()
    prepareFloatingButton()
    prepareMaterialLoader()
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Your Projects")
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
        guard let this = self else { return }
        
        this.drawerViewController?.open()
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = menuButton
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.refreshControl = refreshControl
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(UserProjectCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.items.asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: String(describing: UserProjectCell.self), cellType: UserProjectCell.self)) { (indexPath, model, cell) in
        cell.projectTitle.onNext(model.title)
        cell.projectDescription.onNext(model.description)
        cell.projectImage.onNext(model.image)
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .asObservable()
      .map { [weak self] indexPath in return self?.viewModel.items.value[indexPath.row] }
      .filterNil()
      .subscribe(onNext: { [weak self] project in
        guard let this = self else { return }
        try? this.router.route(from: this, to: UserProjectRouter.Routes.projectDetail.rawValue, parameters: ["id": project.id])
      })
      .disposed(by: disposeBag)
    
    viewModel.deleteProjectSuccess
      .asObservable()
      .subscribe({ _ in
        let message = MDCSnackbarMessage(text: "Project successfully Deleted!")
        MDCSnackbarManager.show(message)
      }).disposed(by: disposeBag)
  }
  
  private func prepareFloatingButton() {
    floatingButton = MDCFloatingButton()
    floatingButton.setTitle("+", for: .normal)
    floatingButton.sizeToFit()
    floatingButton.backgroundColor = MDCPalette.red.tint700
    
    view.addSubview(floatingButton)
    
    floatingButton.snp.makeConstraints { (make) -> Void in
      make.right.equalTo(view).inset(20)
      make.bottom.equalTo(view).inset(20)
    }
    
    floatingButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(from: this, to: UserProjectRouter.Routes.createProject.rawValue)
    }).disposed(by: disposeBag)
    
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
  
  private func prepareEmptyView() {
    emptyUserProjectView = EmptyView(
      imageLiteral: Constants.Icon.assignmentLate,
      title: "No Projects",
      descriptionText: "Add a Project Using the '+' Button Below!"
    )
    emptyUserProjectView.isHidden = true
    
    view.addSubview(emptyUserProjectView)
    
    emptyUserProjectView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.isItemsEmpty
      .map { !$0 }
      .subscribe(onNext: { [weak self] isEmpty in
        self?.emptyUserProjectView.isHidden = isEmpty
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

extension UserProjectViewController: UITableViewDelegate {
  
  //TableViewCell action for deleting projects
  public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let deleteProject = UITableViewRowAction(
      style: .normal,
      title: "Delete Project",
      handler: { [weak self] _, index in
        guard let this = self else { return }
        let alertController = MDCAlertController(title: "Delete Project", message: "Are you sure you want to delete this project?")
        let cancelAction = MDCAlertAction(title: "Cancel")
        let confirmAction = MDCAlertAction(title: "Confirm") { _ in
          this.viewModel.deleteProject.on(.next(indexPath))
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        this.present(alertController, animated: true, completion: nil)
      }
    )
    deleteProject.backgroundColor = MDCPalette.red.tint600
    return [deleteProject]
  }
}
