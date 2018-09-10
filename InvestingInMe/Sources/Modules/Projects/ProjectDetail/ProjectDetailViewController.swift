//
//  ProjectDetailViewController.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents
import RxSwift
import RxDataSources
import JWTDecode

public final class ProjectDetailViewController: UIViewController {
  // MARK: Properties
  private var viewModel: ProjectDetailViewModelProtocol!
  private var router: ProjectDetailRouter!
  
  // MARK: Views
  private var backButton: UIBarButtonItem!
  private var moreButton: UIBarButtonItem!
  private var menuButton: UIBarButtonItem!
  private var deleteButton: UIBarButtonItem!
  private var featureProjectButton: UIBarButtonItem!
  private var profileButtonView: ProfileButtonView!
  private var appBar = MDCAppBar()
  private var tableView: UITableView!
  private var loadingIcon: MaterialLoader!
  
  //Bottom Navigation
  private var bottomNavigationController: BottomNavigationViewController!
  private var shadowView: UIView!
  private var bottomConstraint: Constraint!
  private var heightOffset: CGFloat!
  
  private var dataSource: RxTableViewSectionedReloadDataSource<ProjectDetailViewModel.Section>!

  // MARK: Constraints
  private var profileButtonConstraint: Constraint!
  
  // MARK: Disposeables
  private let disposeBag = DisposeBag()
    
  public convenience init(viewModel: ProjectDetailViewModel, bottomNavigationController: BottomNavigationViewController, router: ProjectDetailRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.bottomNavigationController = bottomNavigationController
    self.router = router
    addChildViewController(appBar.headerViewController)
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
    prepareNavigationAddButton()
    prepareNavigationBackButton()
    prepareShadowView()
    prepareBottomNavigation()
    prepareProfileView()
    prepareMaterialLoader()
    prepareBottomNavigationView()
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Projects")
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
  }
  
  private func prepareNavigationBackButton() {
    // checks if it's in stack
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
  
  private func prepareBottomNavigation() {
    moreButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.moreHorizontal)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    moreButton.tintColor = .white
    
    moreButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.openBottomNavigation()
      }).disposed(by: disposeBag)
    
    viewModel.isProjectOwner
      .asObservable()
      .map{ !$0 }
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        if $0 {
          this.navigationItem.rightBarButtonItem = this.moreButton
        }
      }).disposed(by: disposeBag)
    
  }
  
  private func prepareProfileView() {
    profileButtonView = ProfileButtonView()
    profileButtonView.isHidden = true
    profileButtonView.layer.cornerRadius = 7.5
    profileButtonView.clipsToBounds = true
    
    view.addSubview(profileButtonView)
    
    profileButtonView.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(2.5)
      make.left.equalTo(view).inset(2.5)
      make.right.equalTo(view).inset(2.5)
    }
    
    viewModel.isProjectOwner
      .map { !$0 }
      .do(onNext: { [weak self] owner in
        if owner {
          self?.profileButtonConstraint.update(offset: 0)
        } else {
          self?.profileButtonConstraint.update(offset: -40)
        }
        self?.view.layoutIfNeeded()
      })
      .bind(to: profileButtonView.rx.isHidden)
      .disposed(by: disposeBag)
    
    profileButtonView.rx.tapGesture()
      .filter { [unowned self] _ in return self.viewModel.userId.value != 0 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        try? this.router.route(from: this, to: ProjectDetailRouter.Routes.userProfile.rawValue, parameters: ["userId": this.viewModel.userId.value])
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.separatorStyle = .none
    tableView.registerCell(ProjectDetailTitleCell.self)
    tableView.registerCell(ProjectDetailPageControllerCell.self)
    tableView.registerCell(ProjectDetailTitleViewCell.self)
    tableView.registerCell(ProjectDetailTextCell.self)
    tableView.registerCell(ProjectDetailTextViewCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(view)
      make.left.equalTo(view)
      make.right.equalTo(view)
      profileButtonConstraint = make.bottom.equalTo(view).constraint
    }
    
    dataSource = RxTableViewSectionedReloadDataSource<ProjectDetailViewModel.Section>  (
      configureCell: { [weak self] (dataSource, tableView, indexPath, model) -> UITableViewCell in
        guard let this = self else { return UITableViewCell() }
        switch model {
          case let .header(_, image, title, id):
            let cell = tableView.dequeueCell(ofType: ProjectDetailTitleCell.self, for: indexPath)
            cell.projectImage.onNext(image)
            cell.projectTitle.onNext(title)
            
            //If the contact button is selected, display the SendMessage View Controller
            cell.contactView.rx
              .tapGesture()
              .when(.recognized)
              .asObservable()
              .subscribe(onNext: { _ in
                if(cell.contactLabel.text == "Request Contact") {
                  try? this.router.route(
                    from: this,
                    to: ProjectDetailRouter.Routes.sendMessage.rawValue,
                    parameters: ["userId": id])
                }
              }).disposed(by: cell.disposeBag)
            
            //Check if a connection already exists, display connected
            this.viewModel.connectionExists
              .asObservable()
              .subscribe(onNext: { _ in
                cell.contactLabel.text = "Connected"
                cell.contactView.backgroundColor = MDCPalette.green.tint600
              }).disposed(by: this.disposeBag)
            
            this.viewModel.isProjectOwner
              .asObservable()
              .subscribe(onNext: { owner in
                if !owner {
                  cell.contactLabel.text = "You Own This"
                }
              }).disposed(by: this.disposeBag)
            
            return cell
          case let .assets(_, assets):
            let cell = tableView.dequeueCell(ofType: ProjectDetailPageControllerCell.self, for: indexPath)
            cell.projectAssets.onNext(assets)
            
            // get the current pages index
            cell.currentPage
              .asObservable()
              .bind(to: this.viewModel.assetIndex)
              .disposed(by: cell.disposeBag)
            
            return cell
          case let .title(_, value):
            let cell = tableView.dequeueCell(ofType: ProjectDetailTitleViewCell.self, for: indexPath)
            cell.title.onNext(value)
            return cell
          case let .text(_, value):
            let cell = tableView.dequeueCell(ofType: ProjectDetailTextCell.self, for: indexPath)
            cell.title.onNext(value)
            return cell
          case let .textview(_, value):
            let cell = tableView.dequeueCell(ofType: ProjectDetailTextViewCell.self, for: indexPath)
            cell.value.onNext(value)
            return cell
        }
      }
    )
    
    dataSource.canEditRowAtIndexPath = { _, _ in
      return true      
    }
    
    viewModel.items.asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .asObservable()
      .map { [weak self] indexPath in return self?.viewModel.items.value[indexPath.section].items[indexPath.row] }
      .filterNil()
      .subscribe(onNext: { [weak self] item in
        guard let this = self else { return }
        switch item {
        case let .assets(_, assets):
          if assets.isNotEmpty {
            try? this.router.route(
              from: this,
              to: ProjectDetailRouter.Routes.pageViewer.rawValue,
              parameters: ["assets": assets, "index": this.viewModel.assetIndex.value]
            )
          }
          break
        default:
          break
        }
      }).disposed(by: disposeBag)
    
    //Delete Project
    viewModel.deleteMessageModal
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.closeBottomNavigation()
        let alertController = MDCAlertController(title: "Delete Project", message: "Are you sure you want to delete this project?")
        let cancelAction = MDCAlertAction(title: "Cancel")
        let confirmAction = MDCAlertAction(title: "Confirm") { _ in
          this.viewModel.deleteProject.on(.next(()))
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        this.present(alertController, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.deleteProjectSuccess
      .asObservable()
      .subscribe({ [weak self] _ in
        guard let this = self else { return }
        try? this.router.route(from: this, to: ProjectDetailRouter.Routes.myProjects.rawValue, parameters: nil)
        ModuleFactoryAssembler.makeSnackbarMessage(message: "Project successfully Deleted!")
      }).disposed(by: disposeBag)
    
    //Edit Project
    viewModel.editProject
      .asObservable()
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.closeBottomNavigation()
        try? this.router.route(from: this, to: ProjectDetailRouter.Routes.editProject.rawValue, parameters: ["projectId": this.viewModel.projectId, "viewModel": this.viewModel])
      }).disposed(by: disposeBag)
    
    //Feature Project
    viewModel.featureProject
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.closeBottomNavigation()
        let alertController = MDCAlertController(title: "Feature Project", message: "Are you sure you want to feature this project?")
        let cancelAction = MDCAlertAction(title: "Cancel")
        let confirmAction = MDCAlertAction(title: "Confirm") { _ in
          this.viewModel.feature.on(.next(()))
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        this.present(alertController, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.featureProjectDenied
      .subscribe(onNext: { [weak self] error in
        guard let this = self else { return }
        try? this.router.route(from: this, to: ProjectDetailRouter.Routes.myProjects.rawValue, parameters: nil)
        ModuleFactoryAssembler.makeSnackbarMessage(message: error.reason)
      })
      .disposed(by: disposeBag)
    
    viewModel.featureProjectSuccess
      .asObservable()
      .subscribe({ [weak self] _ in
        guard let this = self else { return }
        try? this.router.route(from: this, to: ProjectDetailRouter.Routes.myProjects.rawValue, parameters: nil)
        ModuleFactoryAssembler.makeSnackbarMessage(message: "Project successfully Featured")
      }).disposed(by: disposeBag)
    
    //Close Bottom Navigation
    viewModel.closeBottomNavigation
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.closeBottomNavigation()
      }).disposed(by: disposeBag)
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
  
  private func prepareShadowView() {
    shadowView = UIView()
    shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    shadowView.alpha = 0
    
    view.addSubview(shadowView)
    
    shadowView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    shadowView.rx.tapGesture()
      .asObservable()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        self?.closeBottomNavigation()
      }).disposed(by: disposeBag)
  }
  
  private func prepareBottomNavigationView() {
    view.addSubview(bottomNavigationController.view)
    addChildViewController(bottomNavigationController)
    bottomNavigationController.didMove(toParentViewController: self)
    heightOffset = bottomNavigationController.tableViewHeight
    
    bottomNavigationController.view.snp.makeConstraints { make in
      make.width.equalTo(view)
      make.height.equalTo(heightOffset)
      bottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).offset(heightOffset).constraint
    }
    self.bottomConstraint.update(offset: self.heightOffset + 30)
  }
  
  private func openBottomNavigation() {
    UIView.animate(withDuration: 0.2) {
      self.bottomConstraint.update(offset: 0)
      self.shadowView.alpha = 0.75
      self.view.layoutIfNeeded()
    }
  }
  
  private func closeBottomNavigation() {
    UIView.animate(withDuration: 0.2) {
      self.bottomConstraint.update(offset: self.heightOffset + 30)
      self.shadowView.alpha = 0
      self.view.layoutIfNeeded()
    }
  }
}

extension ProjectDetailViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
    case .assets:
      return 250
    case .header:
      return 100
    case .textview:
      return UITableViewAutomaticDimension
    case .title:
      return 25
    default:
      return 44
    }
  }
}

