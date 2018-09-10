//
//  FilterProjectViewModel.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-26.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import RxDataSources

public protocol FilterProjectViewModelProtocol {
  var items: Variable<[FilterProjectViewModel.Section]> { get }
  var category: Variable <String?> { get }
  var itemSelected: Observable<IndexPath>!  { get set }
  var role: Variable<String?> { get }
  var categoryQueries: Variable<[String]> { get }
  var roleQueries: Variable<[String]> { get }
  var isEnabled: Observable<Bool> { get }
  func bindButtons()
}

public class FilterProjectViewModel: FilterProjectViewModelProtocol {
  public var categoryQueries: Variable<[String]> = Variable([])
  public var roleQueries: Variable<[String]> = Variable([])
  public var itemSelected: Observable<IndexPath>!
  public var category: Variable<String?> = Variable(nil)
  public var role: Variable<String?> = Variable(nil)
  
  private let disposeBag = DisposeBag()
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  public var items: Variable<[FilterProjectViewModel.Section]> = Variable([])
  
  public var isEnabled: Observable<Bool> {
    return Observable.combineLatest(categoryQueries.asObservable(), roleQueries.asObservable()) { categories, roles in
      return categories.isNotEmpty || roles.isNotEmpty
    }
  }
  
  public init(provider: MoyaProvider<InvestingInMeAPI>) {
    self.provider = provider
    let category = CategoryGroup.allValues
      .enumerated()
      .map { SectionItem.category(order: $0.offset, label: $0.element.rawValue, query: $0.element.rawValue, checked: false) }
    let roles = RoleGroup.allValues
      .enumerated()
      .map { SectionItem.role(order: $0.offset, label: $0.element.rawValue, query: $0.element.rawValue, checked: false) }
    
    let categorySection = Section(order: 0, title: "Category", items: category)
    let roleSection = Section(order: 1, title: "Role", items: roles)
    
    Observable.just([categorySection, roleSection])
      .map {$0.sorted(by: { $0.order < $1.order })}
      .bind(to: items)
      .disposed(by: disposeBag)
    
  }
  
  public func bindButtons() {
      itemSelected
        .map { [unowned self] index in return (index.section, self.items.value[index.section].items[index.row])  }
        .subscribe(onNext:  { [weak self] item in
          guard let this = self else {return}
          //item.checked = !item.checked
          if let index = this.items.value[item.0].items.index(of: item.1) {
            var newItem: SectionItem
            switch this.items.value[item.0].items[index] {
            case .category(let order,  let label,  let query, let checked):
                newItem = .category(order: order, label: label, query: query, checked: !checked)
                if !checked {
                  this.categoryQueries.value.append(query)
                } else {
                  if let index = this.categoryQueries.value.index(of: query) {
                    this.categoryQueries.value.remove(at: index)
                  }
              }
            case .role(let order, let label, let query, let checked):
                newItem = .role(order: order, label: label, query: query, checked: !checked)
                if !checked {
                  this.roleQueries.value.append(query)
                } else {
                  if let index = this.roleQueries.value.index(of: query) {
                    this.roleQueries.value.remove(at: index)
                  }
              }
            }
            this.items.value[item.0].items[index] = newItem
          }
        })
      .disposed(by: disposeBag)
  }
  
}

extension FilterProjectViewModel {
  
  public struct Section {
    public let order: Int
    public let title: String
    public var items: [SectionItem]
  
  }
  
  public enum SectionItem {
    case category(order: Int, label: String, query: String, checked: Bool)
    case role(order: Int, label: String, query: String, checked: Bool)
  }
  
}

extension FilterProjectViewModel.SectionItem {
  public var order: Int {
    switch self {
    case let .category(order, _, _, _):
      return order
      case let .role(order, _, _, _):
      return order
    }
}
  public var checked: Bool {
    switch self {
    case let .category(_, _, _, checked):
      return checked
    case let .role(_, _, _, checked):
      return checked
    }
  }
}

extension FilterProjectViewModel.Section: SectionModelType {
  public init(original: FilterProjectViewModel.Section, items: [FilterProjectViewModel.SectionItem]) {
    self = original
    self.items = items
  }
}

extension FilterProjectViewModel.SectionItem: Equatable {
  public static func ==(lhs: FilterProjectViewModel.SectionItem, rhs: FilterProjectViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
  
  
}


