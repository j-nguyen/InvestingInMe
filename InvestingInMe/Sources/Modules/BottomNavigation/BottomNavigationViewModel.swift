//
//  BottomNavigationViewModel.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-04-01.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

public protocol BottomNavigationViewModelProtocol {
  var items: Variable<[NavigationItem]> { get }
  var itemSelected: Observable<IndexPath>! { get set }
  
  func bindButtons()
}

public class BottomNavigationViewModel: BottomNavigationViewModelProtocol {

  //MARK: - Variables
  public var items: Variable<[NavigationItem]> = Variable([])
  
  //MARK: - Observables
  public var itemSelected: Observable<IndexPath>!
  
  //MAKR: - Provider & Dispose
  private let provider: MoyaProvider<InvestingInMeAPI>
  private var projectId: Int
  private let projectDetailViewModel: ProjectDetailViewModel
  private let disposeBag = DisposeBag()
  
  public init(provider: MoyaProvider<InvestingInMeAPI>, projectDetailViewModel: ProjectDetailViewModel, projectId: Int) {
    self.provider = provider
    self.projectId = projectId
    self.projectDetailViewModel = projectDetailViewModel
    
    items.value = NavigationItem.setupProjectDetailsMenu()
  }
  
  //MARK: - Bind Buttons
  public func bindButtons() {
    itemSelected
      .subscribe(onNext: { [weak self] index in
        guard let this = self else { return }
        switch this.items.value[index.row] {
          case .deleteProject:
            this.projectDetailViewModel.deleteMessageModal.onNext(())
          case .editProject:
            this.projectDetailViewModel.editProject.onNext(())
          case .featureProject:
            this.projectDetailViewModel.featureProject.onNext(())
          case .cancel:
            this.projectDetailViewModel.closeBottomNavigation.onNext(())
        }
      }).disposed(by: disposeBag)
  }
}
