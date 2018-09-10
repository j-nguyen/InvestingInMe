//
//  CreateProjectViewController.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-03.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources
import SnapKit
import MaterialComponents
import Photos
import ImagePicker

public class CreateProjectViewController: UIViewController {
  // MARK: Properties
  private var viewModel: CreateProjectViewModelProtocol!
  private var router: CreateProjectRouter!
  
  // MARK: Views
  private var tableView: UITableView!
  private let appBar = MDCAppBar()
  private var menuButton: UIBarButtonItem!
  private var backButton: UIBarButtonItem!
  private var doneButton: UIBarButtonItem!
  private var loadingIcon: MaterialLoader!
  
  private var imagePicker: ImagePickerController = {
    let imagePicker = ImagePickerController()
    imagePicker.imageLimit = 3
    return imagePicker
  }()
  
  // MARK: Rx
  fileprivate var dataSource: RxTableViewSectionedReloadDataSource<CreateProjectViewModel.Section>!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: CreateProjectViewModel, router: CreateProjectRouter) {
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
    imagePicker.delegate = self
    prepareView()
    appBar.addSubviewsToParent()
  }
  
  private func prepareView() {
    prepareNavigationDoneButton()
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationBackButton()
    prepareKeyboard()
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Create Project")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationBackButton() {
    backButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.backArrow)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    backButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.drawerViewController?.popViewController()
      }).disposed(by: disposeBag)
    
    menuButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.menu)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    menuButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.drawerViewController?.open()
      }).disposed(by: disposeBag)
    
    if (drawerViewController?.isViewControllerInNavStack(self) ?? false) {
      navigationItem.leftBarButtonItems = [backButton, menuButton]
    } else {
      navigationItem.leftBarButtonItem = menuButton
    }
  }
  
  private func prepareNavigationDoneButton() {
    doneButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.done)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    viewModel.isButtonEnabled
      .bind(to: doneButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.doneSelected = doneButton.rx.tap.asObservable()
    
    viewModel.showLoader
      .asObservable()
      .subscribe(onNext: { [weak self] in
        self?.prepareMaterialLoader()
        self?.view.endEditing(true)
      }).disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem = doneButton
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.separatorStyle = .none
    tableView.estimatedRowHeight = 70
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    tableView.keyboardDismissMode = .onDrag
    tableView.registerCell(CreateProjectIconCell.self)
    tableView.registerCell(CreateProjectNameCell.self)
    tableView.registerCell(CreateProjectTextViewCell.self)
    tableView.registerCell(CreateProjectCategoryCell.self)
    tableView.registerCell(CreateProjectScreenshotCell.self)
    tableView.registerCell(CreateProjectRoleCell.self)
    tableView.registerCell(CreateProjectTitleCell.self)
    tableView.registerCell(CreateProjectScreenshotTitleCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedReloadDataSource<CreateProjectViewModel.Section>(
      configureCell: { [weak self] (dataSource, tableView, indexPath, _) -> UITableViewCell in
        guard let this = self else { return UITableViewCell() }
        switch dataSource[indexPath] {
        case let .icon(_, title, imageURL):
          let cell = tableView.dequeueCell(ofType: CreateProjectIconCell.self, for: indexPath)
          cell.title.onNext(title)
          cell.url.onNext(imageURL)
          
          cell.dataImage
            .bind(to: this.viewModel.iconImage)
            .disposed(by: cell.disposeBag)
          
          return cell
        case let .name(_, title, placeholder):
          let cell = tableView.dequeueCell(ofType: CreateProjectNameCell.self, for: indexPath)
          cell.title.onNext(title)
          cell.placeholder.onNext(placeholder)
          
          cell.disposeAll()
          
          cell.disposeable = (cell.textValue <-> this.viewModel.name)
          
          return cell
        case let .description(_, placeholder):
          let cell = tableView.dequeueCell(ofType: CreateProjectTextViewCell.self, for: indexPath)
          cell.placeholder = placeholder
          
          cell.disposeAll()
          
          cell.disposeable = cell.didChange
            .subscribe(onNext: {
              this.updateTextView()
            })
          
          cell.disposeable = (cell.textValue <-> this.viewModel.description)
          
          return cell
        case let .category(_, title, categories):
          let cell = tableView.dequeueCell(ofType: CreateProjectCategoryCell.self, for: indexPath)
          cell.title.onNext(title)
          cell.categories.value = categories
          
          cell.categorySelected
            .bind(to: this.viewModel.category)
            .disposed(by: cell.disposeBag)
          
          return cell
        case let .role(_, title, roles):
          let cell = tableView.dequeueCell(ofType: CreateProjectRoleCell.self, for: indexPath)
          cell.title.onNext(title)
          cell.roles.value = roles
          
          cell.roleSelected
            .bind(to: this.viewModel.role)
            .disposed(by: cell.disposeBag)
          
          return cell
        case let .screenshots(_, assets):
          let cell = tableView.dequeueCell(ofType: CreateProjectScreenshotCell.self, for: indexPath)
          cell.assets.onNext(assets)
          
          cell.dataImage
            .asObservable()
            .bind(to: this.viewModel.screenshotImages)
            .disposed(by: cell.disposeBag)
          
          return cell
        case let .needs(_, placeholder):
          let cell = tableView.dequeueCell(ofType: CreateProjectTextViewCell.self, for: indexPath)
          cell.placeholder = placeholder
        
          cell.disposeable = cell.didChange
            .subscribe(onNext: {
              this.updateTextView()
            })
          
          cell.disposeable = (cell.textValue <-> this.viewModel.needs)

          return cell
        case let .title(_, title):
          let cell = tableView.dequeueCell(ofType: CreateProjectTitleCell.self, for: indexPath)
          cell.title.onNext(title)
          return cell
        case let .screenshotTitle(_, title):
          let cell = tableView.dequeueCell(ofType: CreateProjectScreenshotTitleCell.self, for: indexPath)
          
          cell.title.onNext(title)
          
          cell.addButton.rx
            .tapGesture()
            .when(.recognized)
            .asObservable()
            .subscribe(onNext: {  _ in
              var tempIndexPath = indexPath
              tempIndexPath.row += 1
              this.viewModel.tableIndex.value = tempIndexPath
              this.present(this.imagePicker, animated: true, completion: nil)
            })
            .disposed(by: cell.disposeBag)
          
          return cell
        }
    })
    
    viewModel.items
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.itemSelected = tableView.rx.itemSelected.asObservable()
    viewModel.bindButtons()
    
    viewModel.iconClicked
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        // By Default, this should get the images ONLY
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = this
        imagePicker.allowsEditing = false
        this.present(imagePicker, animated: true)
      }).disposed(by: disposeBag)
    
    viewModel.onDeclinedImage
      .subscribe(onNext: {
        ModuleFactoryAssembler.makeSnackbarMessage(message: "The image(s) you've uploaded were deemed inappropriate!")
      })
      .disposed(by: disposeBag)
    
    // if project was a success, let's create a snack bar message and pop the viewcontroller
    viewModel.onCreateProjectSuccess
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(
          from: this,
          to: CreateProjectRouter.Routes.myProjects.rawValue
        )
        ModuleFactoryAssembler.makeSnackbarMessage(message: "Project successfully added!")
        self?.viewModel.uploadingComplete.onNext(())
      })
      .disposed(by: disposeBag)
    
    viewModel.onError
      .subscribe(onNext: { error in
        ModuleFactoryAssembler.makeSnackbarMessage(message: error.reason)
      })
      .disposed(by: disposeBag)
  }
  
  public func prepareMaterialLoader() {
    loadingIcon = MaterialLoader(frame: .zero, message: "Uploading Project...")
    loadingIcon.startLoad()
    
    view.addSubview(loadingIcon)
    
    loadingIcon.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.uploadingComplete
      .subscribe(onNext: { [weak self] in
        self?.loadingIcon.endLoad()
      })
      .disposed(by: disposeBag)
  }
  
  private func updateTextView() {
    let currentOffset = tableView.contentOffset
    UIView.setAnimationsEnabled(false)
    tableView.beginUpdates()
    tableView.endUpdates()
    UIView.setAnimationsEnabled(true)
    tableView.setContentOffset(currentOffset, animated: false)
  }
  
  private func prepareKeyboard() {
    NotificationCenter.default.rx.notification(.UIKeyboardWillShow)
      .subscribe(onNext: { [weak self] notification in
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        self?.tableView.contentInset.bottom = keyboardFrame.size.height + 100
      })
      .disposed(by: disposeBag)
    
    NotificationCenter.default.rx.notification(.UIKeyboardWillHide)
      .subscribe(onNext: { [weak self] notification in
        self?.tableView.contentInset.bottom = 0
      })
      .disposed(by: disposeBag)
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

// MARK: UITableViewDelegate
extension CreateProjectViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
    case .icon:
      return 120
    case .screenshots:
      return 200
    case .description, .needs:
      return UITableViewAutomaticDimension
    default:
      return 50
    }
  }
}

// MARK: UIImagePickerControllerDelegate
extension CreateProjectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let imageURL = info[UIImagePickerControllerImageURL] as? URL else {
      return
    }
    
    dismiss(animated: true, completion: { [weak self] in
      self?.viewModel.iconSetImageURL.onNext(imageURL)
    })
  }
}

// MARK: ImagePickerControllerDelegate
extension CreateProjectViewController: ImagePickerDelegate {
  public func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) { }
  
  public func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    self.dismiss(animated: true, completion: { [weak self] in
      self?.viewModel.onScreenshotSetImages.onNext(images)
    })
  }
  
  public func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    self.dismiss(animated: true, completion: nil)
  }
}
