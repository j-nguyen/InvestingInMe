//
//  SettingsViewController.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-19.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents
import RxSwift
import RxDataSources
import MessageUI

public class SettingsViewController: UIViewController {
  
  // MARK: Settings Properties
  private var viewModel: SettingsViewModelProtocol!
  private var router: SettingsRouter!
  
  // MARK: App Bar Settings
  private let appBar = MDCAppBar()
  private var menuButton: UIBarButtonItem!
  
  // MARK: Views
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<SettingsViewModel.Section>!
  
  // MARK: RxDisposeables
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: SettingsViewModelProtocol, router: SettingsRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
    addChildViewController(appBar.headerViewController)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
    appBar.addSubviewsToParent()
  }
  
  private func prepareView() {
    prepareTableView()
    prepareNavigationBar()
    prepareNavigationMenu()
  }
  
  private func prepareTableView() {
    tableView = UITableView(frame: .zero, style: .grouped)
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.registerCell(SettingsDescriptionCell.self)
    tableView.registerCell(SettingsSwitchCell.self)
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedReloadDataSource<SettingsViewModel.Section>(
      configureCell: { [weak self] (dataSource, tableView, indexPath, item) -> UITableViewCell in
        guard let this = self else { return UITableViewCell() }
        switch item {
        case let .build(_, buildNumber):
          let cell = tableView.dequeueCell(ofType: SettingsDescriptionCell.self, for: indexPath)
          cell.textLabel?.text = "Build Number"
          cell.detailTextLabel?.text = buildNumber
          return cell
        case let .version(_, version):
          let cell = tableView.dequeueCell(ofType: SettingsDescriptionCell.self, for: indexPath)
          cell.textLabel?.text = "Version"
          cell.detailTextLabel?.text = version
          return cell
        case let .disconnect(_, title):
          let cell = tableView.dequeueCell(ofType: SettingsDescriptionCell.self, for: indexPath)
          cell.textLabel?.text = title
          return cell
        case let .logout(_, title):
          let cell = tableView.dequeueCell(ofType: SettingsDescriptionCell.self, for: indexPath)
          cell.textLabel?.text = title
          return cell
        case let .report(_, title):
          let cell = tableView.dequeueCell(ofType: SettingsDescriptionCell.self, for: indexPath)
          cell.textLabel?.text = title
          return cell
        case let .url(_, title, _):
          let cell = tableView.dequeueCell(ofType: SettingsDescriptionCell.self, for: indexPath)
          cell.textLabel?.text = title
          cell.accessoryType = .disclosureIndicator
          return cell
        case let .license(_, title):
          let cell = tableView.dequeueCell(ofType: SettingsDescriptionCell.self, for: indexPath)
          cell.textLabel?.text = title
          cell.accessoryType = .disclosureIndicator
          return cell
        case let .pushNotifications(_, title, isOn):
          let cell = tableView.dequeueCell(ofType: SettingsSwitchCell.self, for: indexPath)
          cell.title.onNext(title)
          cell.isOn.onNext(isOn)
          
          cell.disposeable = cell.value
            .asObservable()
            .subscribe(onNext: { value in
              this.viewModel.onUpdatePushNotifications.onNext(value)
            })
          
          return cell
        }
      }
    )
    
    dataSource.titleForHeaderInSection = { (dataSource, indexPath) in
      return dataSource[indexPath].title
    }
    
    viewModel.sendEmail
      .asObservable()
      .subscribe(onNext: { [weak self] email in
        guard let this = self else { return }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = this
        composeVC.setToRecipients([email.0])
        composeVC.setCcRecipients(email.1)
        composeVC.setSubject(email.2)
        
        this.present(composeVC, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.canSendMail
      .subscribe(onNext: {
        let message = MDCSnackbarMessage(text: "Can't open mail!")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
    
    viewModel.onURLSend
      .asObservable()
      .subscribe(onNext: { [weak self] data in
        guard let this = self else { return }
        try? this.router.route(
          to: SettingsRouter.Routes.url.rawValue,
          from: this,
          parameters: [
            "title": data.0,
            "url": data.1
          ]
        )
      })
      .disposed(by: disposeBag)
    
    viewModel.onSettingsSend
      .subscribe(onNext: {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
          return
        }
        // open
        if UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.items
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    viewModel.itemSelected = tableView.rx.itemSelected.asObservable()
    
    viewModel.bindCell()
    
    viewModel.disconnectSuccess
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(
          to: SettingsRouter.Routes.disconnect.rawValue,
          from: this
        )
      })
      .disposed(by: disposeBag)
    
    viewModel.logoutSuccess
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        try? this.router.route(
          to: SettingsRouter.Routes.login.rawValue,
          from: this
        )
      }).disposed(by: disposeBag)
  }
  
  private func prepareNavigationBar() {
    appBar.headerViewController.headerView.backgroundColor = MDCPalette.red.tint700
    appBar.navigationBar.tintColor = UIColor.white
    appBar.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor: UIColor.white ]
    
    appBar.headerViewController.headerView.trackingScrollView = tableView
    
    Observable.just("Settings")
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)
    
    appBar.navigationBar.observe(navigationItem)
  }
  
  private func prepareNavigationMenu() {
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
  
  deinit {
    appBar.navigationBar.unobserveNavigationItem()
  }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
  public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    // let's check our result
    if result == .sent {
      ModuleFactoryAssembler.makeSnackbarMessage(message: "Successfully sent email message to the developers!")
    } else if result == .failed || result == .cancelled {
      ModuleFactoryAssembler.makeSnackbarMessage(message: "Could not send mail! Are you connected to the internet?")
    }
    
    controller.dismiss(animated: true, completion: nil)
  }
}
