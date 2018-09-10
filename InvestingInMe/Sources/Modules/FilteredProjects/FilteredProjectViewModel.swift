//
//  FilteredProjectViewModel.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-05.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import Moya

public protocol FilteredProjectViewModelProtocol {
  var items: Variable<[FilteredProjectViewModel.SectionItem]> { get }
  var isItemsEmpty: Observable<Bool> { get }
}

public class FilteredProjectViewModel: FilteredProjectViewModelProtocol {
 
  private let disposeBag = DisposeBag()
  private let provider: MoyaProvider<InvestingInMeAPI>
  private let categories: [String]
  private let roles: [String]
  
  public var items: Variable<[FilteredProjectViewModel.SectionItem]> = Variable([])
  
  public var isItemsEmpty: Observable<Bool> {
    return items.asObservable().map { $0.isEmpty }
  }
  
  public init(provider: MoyaProvider<InvestingInMeAPI>, categories: [String], roles: [String]) {
    self.provider = provider
    self.categories = categories
    self.roles = roles
    
    let filteredProjects = requestFilteredProjects(categories: categories, roles: roles).materialize().share()
    
    filteredProjects
      .elements()
      .map{ $0.map{ SectionItem(id: $0.id, title: $0.name, category: $0.category.type, role: $0.role.role, image: $0.assets.first(where: { $0.project_icon })!.url)}}
      .bind(to: items)
      .disposed(by: disposeBag)
    
  }
  
  private func requestFilteredProjects(categories: [String], roles: [String]) -> Observable<[Project]> {
    return provider.rx.request(.allProjects(categories, roles, nil))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map([Project].self)
  }
}

extension FilteredProjectViewModel {
  public struct SectionItem {
    public let id: Int
    public let title: String
    public let category: String
    public let role: String
    public let image: URL
  }
}


