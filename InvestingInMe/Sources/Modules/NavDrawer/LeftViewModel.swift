//
//  LeftViewModel.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-08.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import JWTDecode
import RxDataSources

public protocol LeftViewModelProtocol {
  var items: Variable<[LeftViewModel.Section]> { get }
}

public class LeftViewModel: LeftViewModelProtocol {
  private let provider: MoyaProvider<InvestingInMeAPI>
  private let disposeBag = DisposeBag()
  
  public var items: Variable<[LeftViewModel.Section]> = Variable([])
  public var itemSelected: Observable<IndexPath>!
  
  public init(provider: MoyaProvider<InvestingInMeAPI>) {
    self.provider = provider
    
    let user = requestUser().materialize().share()
    
    // Set up the links inside
    user
      .map { $0.element }
      .filterNil()
      .map { SectionItem.profile(order: 0, name: $0.name, profile: $0.picture, email: $0.email) }
      .toArray()
      .map { items -> [SectionItem] in
        var sectionItems = items
        let links = LeftViewRouter.Routes.allValues
        let sectionLinkItems = links.enumerated().map { SectionItem.link(order: $0.offset, name: $0.element[0], route: $0.element[1]) }
        sectionItems.append(contentsOf: sectionLinkItems)
        return sectionItems
      }
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .map { Section(title: "", items: $0) }
      .toArray()
      .bind(to: items)
      .disposed(by: disposeBag)
  }
  
  /// Request function to get the users, given the token
  private func requestUser() -> Observable<User> {
    let token = UserDefaults.standard.string(forKey: "token") ?? ""
    let jwt = try? decode(jwt: token)
    return Observable.just(jwt)
      .map { $0?.body["user_id"] as? Int }
      .filterNil()
      .flatMap { [unowned self] id in return self.provider.rx.request(.user(id)).asObservable() }
      .filterSuccessfulStatusCodes()
      .map(User.self)
  }
}

extension LeftViewModel {
  public struct Section {
    public let title: String
    public var items: [SectionItem]
  }
  
  public enum SectionItem {
    case profile(order: Int, name: String, profile: URL, email: String)
    case link(order: Int, name: String, route: String)
  }
}

extension LeftViewModel.Section: SectionModelType {
  public typealias Item = LeftViewModel.SectionItem
  
  public init(original: LeftViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}

extension LeftViewModel.SectionItem {
  public var order: Int {
    switch self {
    case let .profile(order, _, _, _):
      return order
    case let .link(order, _, _):
      return order
    }
  }
  
}
