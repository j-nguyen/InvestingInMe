//
//  ProfileViewController.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import MaterialComponents

public class ProfileViewController: UIViewController {
  
  //UIView
  private var viewModel: ProfileViewModelProtocol!
  private var router: ProfileRouter!
  
  //AppBar
  private var menuButton: UIBarButtonItem!
  private var editButton: UIBarButtonItem!
  private var backButton: UIBarButtonItem!
  private var appBar = MDCAppBar()
  
  //Loading Icon
  private var loadingIcon: MaterialLoader!
  
  //TableView
  private var tableView: UITableView!
  
  private let disposeBag = DisposeBag()
  private var dataSource: RxTableViewSectionedReloadDataSource<ProfileViewModel.Section>!
  
  public convenience init(viewModel: ProfileViewModel, router: ProfileRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
    
    addChildViewController(appBar.headerViewController)
  }
  
  public override init(nibName nibNameOrNil: String?,
                       bundle nibBundleOrNil: Bundle?) {
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
    prepareEditButton()
    prepareMaterialLoader()
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Profile")
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
  
  private func prepareEditButton() {
    editButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.modeEdit)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )

    let isEditable = viewModel.canEdit.share()
  
    isEditable
      .bind(to: editButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    editButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(from: this,
          to: EditProfileRouter.Routes.profile.rawValue,
          parameters: ["user_id": this.viewModel.userId, "viewModel": this.viewModel])
      })
      .disposed(by: disposeBag)
    
    isEditable
      .asObservable()
      .subscribe(onNext: { nav in
        if(nav) { self.navigationItem.rightBarButtonItem = self.editButton }
      })
    .disposed(by: disposeBag)
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.registerCell(ProfileImageCell.self)
    tableView.registerCell(ProfileTitleCell.self)
    tableView.registerCell(ProfileTextViewCell.self)
    tableView.registerCell(ProfileTextCell.self)

    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    // configure dataSource
    dataSource = RxTableViewSectionedReloadDataSource<ProfileViewModel.Section>(
      configureCell: { (dataSource, tableView, index, section) in
        switch dataSource[index] {
          case let .picture(_, picture, value):
            let cell = tableView.dequeueCell(ofType: ProfileImageCell.self, for: index)
            cell.profileImage.on(.next(picture))
            cell.profileName.on(.next(value))
            return cell
          case let .text(_, title, value):
            let cell = tableView.dequeueCell(ofType: ProfileTextCell.self, for: index)
            cell.title.onNext(title)
            cell.textValue.onNext(value)
            return cell
          case let .textview(_, value):
            let cell = tableView.dequeueCell(ofType: ProfileTextViewCell.self, for: index)
            cell.value.onNext(value)
            return cell
          case let .title(_, value):
            let cell = tableView.dequeueCell(ofType: ProfileTitleCell.self, for: index)
            cell.title.onNext(value)
            return cell
        }
    })
    
    viewModel.section
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
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

extension ProfileViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
      case .textview:
        return UITableViewAutomaticDimension
      case .picture:
        return 100
      case .title:
        return 44
      default:
        return 54
    }
  }
  
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
}
