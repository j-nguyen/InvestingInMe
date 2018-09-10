//
//  LeftViewController.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MaterialComponents
import SnapKit

public class LeftViewController: UIViewController {
  private var viewModel: LeftViewModelProtocol!
  private var router: LeftViewRouter!
  
  // MARK: Views
  private var tableView: UITableView!
  private var dataSource: RxTableViewSectionedReloadDataSource<LeftViewModel.Section>!
  
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: LeftViewModel, router: LeftViewRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
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
  }
  
  private func prepareView() {
    prepareTableView()
  }
  
  private func prepareTableView() {
    tableView = UITableView()
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.alwaysBounceVertical = false
    tableView.separatorStyle = .none
    tableView.backgroundColor = MDCPalette.grey.tint300
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.registerCell(LeftViewHeaderCell.self)
    tableView.registerCell(LeftViewLinkCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    dataSource = RxTableViewSectionedReloadDataSource<LeftViewModel.Section>(
      configureCell: { [weak self] (dataSource, tableView, indexPath, model) -> UITableViewCell in
        guard let _ = self else { return UITableViewCell() }
        switch model {
        case let .profile(_, name, profile, email):
          let cell = tableView.dequeueCell(ofType: LeftViewHeaderCell.self, for: indexPath)
          cell.name.onNext(name)
          cell.profile.onNext(profile)
          cell.email.onNext(email)
          return cell
        case let .link(_, name, _):
          let cell = tableView.dequeueCell(ofType: LeftViewLinkCell.self, for: indexPath)
          cell.name.onNext(name)
          return cell
        }
      }
    )
    
    dataSource.titleForHeaderInSection = { _, _ in return "" }
    
    viewModel.items
      .asObservable()
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .asObservable()
      .map { [weak self] index in return self?.viewModel.items.value[index.section].items[index.row] }
      .filterNil()
      .subscribe(onNext: { [weak self] section in
        guard let this = self else { return }
        switch section {
        case let .link(_, _, route):
          try? this.router.route(to: route, from: this)
        default:
          break
        }
      }).disposed(by: disposeBag)
  }
}


extension LeftViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch dataSource[indexPath] {
    case .profile:
      return 170
    default:
      return 44
    }
  }
}
