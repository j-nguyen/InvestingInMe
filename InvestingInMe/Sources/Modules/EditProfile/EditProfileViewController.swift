//
//  EditProfileViewController.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import MaterialComponents

public final class EditProfileViewController: UIViewController {
  
  //MARK: Required Variables
  private var viewModel: EditProfileViewModelProtocol!
  private var router: EditProfileRouter!
  
  //MARK: AppBar Properties
  private let appBar: MDCAppBar = MDCAppBar()
  private var closeButton: UIBarButtonItem!
  private var saveButton: UIBarButtonItem!
  
  //MARK: TableView
  private var tableView: UITableView!
  fileprivate var dataSource: RxTableViewSectionedReloadDataSource<EditProfileViewModel.Section>!
  
  //MARK: Dispose
  private let disposeBag: DisposeBag = DisposeBag()
  
  //MARK: Initializers
  //Declare the ViewController convenience initializer
  public convenience init(viewModel: EditProfileViewModel, router: EditProfileRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
    
    //Add the appBar header to the ViewController
    addChildViewController(appBar.headerViewController)
  }

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override var childViewControllerForStatusBarStyle: UIViewController? {
    return appBar.headerViewController
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNeedsStatusBarAppearanceUpdate()
    
    //Set the nav bar to hidden state so we can give a custom appearance to it
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    //Set the views background color
    view.backgroundColor = .white
    
    //Call the prepareView function
    prepareView()
  }
  
  //MARK: PrepareView
  private func prepareView() {
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationCloseButton()
    prepareNavigationSaveButton()
    appBar.addSubviewsToParent()
  }
  
  private func prepareTableView() {
    
    //Declare the tableView properties, delegate, and register cells
    tableView = UITableView()
    tableView.separatorStyle = .none
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    tableView.estimatedRowHeight = 70
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.keyboardDismissMode = .onDrag

    tableView.registerCell(EditProfileTextViewCell.self)
    tableView.registerCell(EditProfileTextFieldCell.self)
    tableView.registerCell(EditProfileRoleCell.self)
    tableView.registerCell(EditProfileTitleCell.self)
    
    //Add the tableView to the view
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    //Set the dataSource of the tableView
    dataSource = RxTableViewSectionedReloadDataSource(
      configureCell: { [weak self] dataSource, tableView, index, model in
        guard let this = self else { return UITableViewCell() }
        
        //Set the EditProfile Cells, and bind the new values to the ViewModel
        switch dataSource[index] {
          case let .location(_, location, value, placeholder):
            let cell = tableView.dequeueCell(ofType: EditProfileTextFieldCell.self, for: index)
            cell.title.onNext(location)
            cell.value.onNext(value)
            cell.placeholder.onNext(placeholder)
            
            cell.textValue
              .orEmpty
              .map { $0.encode }
              .filterNil()
              .bind(to: this.viewModel.location)
              .disposed(by: cell.disposeBag)
            
            return cell
          case let .description(_, description, placeholder):
            let cell = tableView.dequeueCell(ofType: EditProfileTextViewCell.self, for: index)
            cell.textValue.onNext(description)
            cell.placeholder = placeholder
            
            cell.didChange
              .subscribe(onNext: {
                this.updateTextView()
              })
              .disposed(by: cell.disposeBag)
            
            cell.textControl
              .map { $0.encode }
              .filterNil()
              .bind(to: this.viewModel.description)
              .disposed(by: cell.disposeBag)
            
            return cell
          case let .phone_number(_, phone, value, placeholder):
            let cell = tableView.dequeueCell(ofType: EditProfileTextFieldCell.self, for: index)
            cell.title.onNext(phone)
            cell.value.onNext(value)
            cell.placeholder.onNext(placeholder)
            cell.keyboardType = .numberPad
            
            cell.textValue
              .orEmpty
              .map { $0.encode }
              .filterNil()
              .bind(to: this.viewModel.phone_number)
              .disposed(by: cell.disposeBag)
                        
            return cell
          case let .experience_and_credentials(_, experience_and_credentials, placeholder):
            let cell = tableView.dequeueCell(ofType: EditProfileTextViewCell.self, for: index)
            cell.placeholder = placeholder
            cell.textValue.onNext(experience_and_credentials)
            
            cell.didChange
              .subscribe(onNext: {
                this.updateTextView()
              })
              .disposed(by: cell.disposeBag)
            
            cell.textControl
              .map { $0.encode }
              .filterNil()
              .bind(to: this.viewModel.experience_and_credentials)
              .disposed(by: cell.disposeBag)
            
            return cell
          case let .role(_, role, roles):
            let cell = tableView.dequeueCell(ofType: EditProfileRoleCell.self, for: index)
            cell.editProfileRole.on(.next(role))
            cell.roles.value = roles
            cell.modelSelected
              .map{ $0.id }
              .bind(to: this.viewModel.role)
              .disposed(by: cell.disposeBag)
            
            return cell
          case let .title(_, value):
            let cell = tableView.dequeueCell(ofType: EditProfileTitleCell.self, for: index)
            cell.title.onNext(value)
            return cell
        }
      }
    )
    
    //Bind the viewModel Section to the tableView items datasource
    viewModel.section
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
  private func prepareNavigationBar() {
    
    //Set the nav bar title, colors, and properties
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Edit Profile")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationCloseButton() {
    
    //Set the close button properties and method calls
    closeButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.close)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    closeButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = closeButton
  }
  
  private func prepareNavigationSaveButton() {
    
    //Set the save button properties and method calls
    saveButton = UIBarButtonItem(
      title: "Save",
      style: .plain,
      target: nil,
      action: nil
    )
    
    viewModel.submitButtonTap = saveButton.rx.tap.asObservable()

    viewModel.submitButtonSuccess
      .asObservable()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.dismiss(animated: true, completion: {
          this.viewModel.reloadProfile.onNext(())
          ModuleFactoryAssembler.makeSnackbarMessage(message: "Successfully edited profile!")
        })
      })
      .disposed(by: disposeBag)
    
    viewModel.submitButtonFail
      .asObservable()
      .subscribe(onNext: { response in
        ModuleFactoryAssembler.makeSnackbarMessage(message: response.reason)
      })
      .disposed(by: disposeBag)
    
    viewModel.bindButtons()
    
    navigationItem.rightBarButtonItem = saveButton
  }
  
  private func updateTextView() {
    let currentOffset = tableView.contentOffset
    UIView.setAnimationsEnabled(false)
    tableView.beginUpdates()
    tableView.endUpdates()
    UIView.setAnimationsEnabled(true)
    tableView.setContentOffset(currentOffset, animated: false)
  }
}
