//
//  BottomNavigationController.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-04-01.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import RxCocoa
import RxDataSources

public class BottomNavigationViewController: UIViewController {
  private var viewModel: BottomNavigationViewModelProtocol!
  private var router: BottomNavigationRouter!
  
  private var tableView: UITableView!
  
  private let disposeBag = DisposeBag()
  
  public var tableViewHeight: CGFloat {
    self.view.layoutIfNeeded()
    return tableView.contentSize.height
  }
  
  public convenience init(viewModel: BottomNavigationViewModelProtocol, router: BottomNavigationRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
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
    tableView.isScrollEnabled = false
    tableView.separatorInset = .zero
    tableView.separatorStyle = .none
    tableView.registerCell(NavigationCell.self)
    
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
    
    viewModel.items
      .asObservable()
      .bind(to: tableView.rx.items(cellIdentifier: String(describing: NavigationCell.self), cellType: NavigationCell.self)) { (row,  element, cell) in
        let image = UIImage(named: element.image)?.withRenderingMode(.alwaysTemplate)
        cell.title.onNext(element.title)
        cell.iconImage.onNext(image)
      }.disposed(by: disposeBag)
    
    viewModel.itemSelected = tableView.rx.itemSelected.asObservable()
    viewModel.bindButtons()
  }
}
