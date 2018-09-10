//
//  EditProjectViewController.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-30.
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

public class EditProjectViewController: UIViewController {
  // MARK: Properties
  private var viewModel: EditProjectViewModel!
  private var detailViewModel: ProjectDetailViewModel!
  private var router: EditProjectRouter!
  private var projectId: Int!
  
  // MARK: Views
  private let appBar = MDCAppBar()
  private var backButton: UIBarButtonItem!
  private var saveButton: UIBarButtonItem!
  private var loadingIcon: MaterialLoader!
  private var tableView: UITableView!
  
  // MARK: Rx
  fileprivate var dataSource: RxTableViewSectionedReloadDataSource<EditProjectViewModel.Section>!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: EditProjectViewModel, detailViewModel: ProjectDetailViewModel, router: EditProjectRouter, projectId: Int) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.detailViewModel = detailViewModel
    self.router = router
    self.projectId = projectId
    
    addChildViewController(appBar.headerViewController)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
    appBar.addSubviewsToParent()
  }
  
  private func prepareView() {
    prepareNavigationBar()
    prepareNavigationBackButton()
    prepareNavigationSaveButton()
    prepareTableView()
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Edit Project")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationBackButton() {
    backButton = UIBarButtonItem(
      image: UIImage(named: Constants.Icon.close)?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: nil,
      action: nil
    )
    
    backButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        let alertController = MDCAlertController(title: "Are You Sure", message: "Any changes you've made so far (excluding images) won't be saved if you proceed.")
        let cancelAction = MDCAlertAction(title: "Cancel")
        let confirmAction = MDCAlertAction(title: "Proceed") { _ in
          this.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        this.present(alertController, animated: true, completion: nil)
      }).disposed(by: disposeBag)
    
    navigationItem.leftBarButtonItem = backButton
  }
  
  private func prepareNavigationSaveButton() {
    saveButton = UIBarButtonItem(
      title: "Save",
      style: .plain,
      target: nil,
      action: nil
    )
    
    viewModel.isButtonEnabled
      .bind(to: saveButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.doneSelected = saveButton.rx.tap.asObservable()
    
    viewModel.showLoader
      .asObservable()
      .subscribe(onNext: { [weak self] in
        self?.prepareMaterialLoader()
        self?.view.endEditing(true)
      }).disposed(by: disposeBag)
    
    navigationItem.rightBarButtonItem = saveButton
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.separatorStyle = .none
    tableView.estimatedRowHeight = 70
    tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 100, right: 0)
    tableView.keyboardDismissMode = .onDrag
    tableView.registerCell(CreateProjectIconCell.self)
    tableView.registerCell(CreateProjectNameCell.self)
    tableView.registerCell(CreateProjectTextViewCell.self)
    tableView.registerCell(CreateProjectCategoryCell.self)
    tableView.registerCell(EditProjectScreenshotCell.self)
    tableView.registerCell(CreateProjectRoleCell.self)
    tableView.registerCell(CreateProjectTitleCell.self)
    tableView.registerCell(CreateProjectScreenshotTitleCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedReloadDataSource<EditProjectViewModel.Section>(
      configureCell: { [weak self] (dataSource, tableView, indexPath, _) -> UITableViewCell in
        guard let this = self else { return UITableViewCell() }
        switch dataSource[indexPath] {
        case let .icon(_, title, imageURL):
          let cell = tableView.dequeueCell(ofType: CreateProjectIconCell.self, for: indexPath)
          cell.title.onNext(title)
          cell.url.onNext(imageURL)
          
          cell.dataImage
            .asObservable()
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
            .subscribe(onNext: { _ in
              this.updateTextView()
            })
          
          cell.disposeable = (cell.textValue <-> this.viewModel.description)
          return cell
        case let .category(_, title, categories, currentCategory):
          let cell = tableView.dequeueCell(ofType: CreateProjectCategoryCell.self, for: indexPath)
          cell.title.onNext(title)
          cell.categories.value = categories
          cell.currentCategory.onNext(currentCategory)
          
          cell.categorySelected
            .bind(to: this.viewModel.category)
            .disposed(by: cell.disposeBag)
          
          return cell
        case let .role(_, title, roles, currentRole):
          let cell = tableView.dequeueCell(ofType: CreateProjectRoleCell.self, for: indexPath)
          cell.title.onNext(title)
          cell.roles.value = roles
          cell.currentRole.onNext(currentRole)
          
          cell.roleSelected
            .bind(to: this.viewModel.role)
            .disposed(by: cell.disposeBag)
                    
          return cell
        case let .screenshots(_, assets):
          let cell = tableView.dequeueCell(ofType: EditProjectScreenshotCell.self, for: indexPath)
          cell.assets.onNext(assets)
          return cell
        case let .needs(_, placeholder):
          let cell = tableView.dequeueCell(ofType: CreateProjectTextViewCell.self, for: indexPath)
          cell.placeholder = placeholder
          cell.disposeAll()
          
          cell.disposeable = cell.didChange
            .subscribe(onNext: {
              this.updateTextView()
            })
          
          cell.disposeable = cell.didBeginEditing
            .subscribe(onNext: {
              this.tableView.setContentOffset(CGPoint(x: 0, y: 550), animated: true)
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
              let alertController = MDCAlertController(title: "Warning", message: "Uploading new images to your project will result in deleting all current images! Are you sure you would like to proceed?")
              let cancelAction = MDCAlertAction(title: "Cancel")
              let confirmAction = MDCAlertAction(title: "Proceed") { _ in
                let imagePicker = ImagePickerController()
                imagePicker.imageLimit = 3
                imagePicker.delegate = this
                var tempIndexPath = indexPath
                tempIndexPath.row += 1
                this.viewModel.tableIndex.value = tempIndexPath
                this.present(imagePicker, animated: true, completion: nil)
              }
              alertController.addAction(confirmAction)
              alertController.addAction(cancelAction)
              this.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: cell.disposeBag)
          
          return cell
        }
    })
    
    dataSource.canEditRowAtIndexPath = { _, _ in
      return true
    }
    
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
        let alertController = MDCAlertController(title: "Warning", message: "Uploading a new icon to your project will result in deleting the current icon! Are you sure you would like to proceed?")
        let cancelAction = MDCAlertAction(title: "Cancel")
        let confirmAction = MDCAlertAction(title: "Proceed") { _ in
          // By Default, this should get the images ONLY
          let imagePicker = UIImagePickerController()
          imagePicker.sourceType = .photoLibrary
          imagePicker.delegate = this
          imagePicker.allowsEditing = false
          this.present(imagePicker, animated: true)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        this.present(alertController, animated: true, completion: nil)
      }).disposed(by: disposeBag)
    
    viewModel.onDeclinedImage
      .subscribe(onNext: {
        ModuleFactoryAssembler.makeSnackbarMessage(message: "The image(s) you've uploaded were deemed inappropriate!")
      })
      .disposed(by: disposeBag)
    
    viewModel.updateComplete
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.dismiss(animated: true, completion: {
          this.detailViewModel.refreshContent.on(.next(()))
          ModuleFactoryAssembler.makeSnackbarMessage(message: "Project successfully updated!")
        })
      }).disposed(by: disposeBag)
    
    viewModel.onError
      .subscribe(onNext: { message in
        ModuleFactoryAssembler.makeSnackbarMessage(message: message)
      })
      .disposed(by: disposeBag)
  }
  
  public func prepareMaterialLoader() {
    loadingIcon = MaterialLoader(frame: .zero, message: "Uploading New Assets...")
    loadingIcon.startLoad()
    
    view.addSubview(loadingIcon)
    
    loadingIcon.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.iconUploadSuccess
      .subscribe(onNext: { [weak self] in
        self?.loadingIcon.endLoad()
      }).disposed(by: disposeBag)
    
    viewModel.assetsUploadSuccess
      .subscribe(onNext: { [weak self] in
        self?.loadingIcon.endLoad()
      }).disposed(by: disposeBag)
  }
  
  private func updateTextView() {
    let currentOffset = tableView.contentOffset
    UIView.setAnimationsEnabled(false)
    tableView.beginUpdates()
    tableView.endUpdates()
    UIView.setAnimationsEnabled(true)
    tableView.setContentOffset(currentOffset, animated: false)
  }
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

// MARK: UITableViewDelegate
extension EditProjectViewController: UITableViewDelegate {
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
extension EditProjectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
extension EditProjectViewController: ImagePickerDelegate {
  public func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) { }
  
  public func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    self.dismiss(animated: true)
    self.viewModel.onScreenshotSetImages.onNext(images)
  }
  
  public func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    self.dismiss(animated: true)
  }
}

