//
//  SearchProjectViewModel.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import Moya

public protocol SearchProjectViewModelProtocol {
  var searchProjects: Variable<String> { get }
  var projects: Variable<[Project]> { get }
  var isItemsEmpty: Observable<Bool> { get }
}

public class SearchProjectViewModel: SearchProjectViewModelProtocol {
  
  private let disposeBag = DisposeBag()
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  public var searchProjects: Variable<String> = Variable("")
  public var projects: Variable<[Project]> = Variable([])
  
  public var isItemsEmpty: Observable<Bool> {
    return projects.asObservable().map { $0.isEmpty }
  }
  
  public init(provider: MoyaProvider<InvestingInMeAPI>) {
    self.provider = provider
    
    searchProjects
      .asObservable()
      .throttle(0.4, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .flatMapLatest { query -> Observable<[Project]> in
        if query.isEmpty {
          return Observable.just([])
        }
        return self.requestProjects(query: query)
          .catchErrorJustReturn([])
      }
      .bind(to: projects)
      .disposed(by: disposeBag)
    
  }
  
  private func requestProjects(query: String) -> Observable<[Project]> {
    return provider.rx.request(.allProjects(nil, nil, query))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map([Project].self)
  }
}
