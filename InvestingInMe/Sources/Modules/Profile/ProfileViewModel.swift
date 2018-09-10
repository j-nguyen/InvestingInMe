//
//  ProfileViewModel.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxOptional
import Moya
import JWTDecode

public protocol ProfileViewModelProtocol {
  var section: Variable<[ProfileViewModel.Section]> { get }
  var userId: Int { get }
  var canEdit: Observable<Bool> { get }
  var refreshContent: PublishSubject<Void> { get }
  var loadingComplete: PublishSubject<Void> { get }
}

public class ProfileViewModel: ProfileViewModelProtocol {
  private let provider: MoyaProvider<InvestingInMeAPI>!

  public var section: Variable<[ProfileViewModel.Section]> = Variable([])
  
  public var refreshContent: PublishSubject<Void> = PublishSubject()
  public var loadingComplete: PublishSubject<Void> = PublishSubject()
  
  private let disposeBag = DisposeBag()
  public let userId: Int
  
  public var canEdit: Observable<Bool> {
    return user(userId: self.userId)
      .map { $0.id }
      .map { userId -> Bool in
        let token = UserDefaults.standard.string(forKey: "token")
        let jwt = try? decode(jwt: token!)
        if let tokenId = jwt?.body["user_id"] as? Int {
          return tokenId == userId
        }
        return false
    }
  }
  
  public init(provider: MoyaProvider<InvestingInMeAPI>, userId: Int) {
    self.provider = provider
    self.userId = userId
    
    refreshContent
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.setup()
      }).disposed(by: disposeBag)

    setup()
  }
  
  private func setup() {
    let requestedUser = user(userId: userId)
      .do(onNext: { [weak self] _ in
        self?.loadingComplete.onNext(())
      })
      .materialize()
      .share()
    
    let elements = requestedUser.map { $0.element }.filterNil()
    
    let pictureDetails =
      elements.map { user -> [SectionItem] in
        return [
          SectionItem.picture(order: 0, picture: user.picture, value: user.name),
        ].sorted(by: { $0.order < $1.order })
      }
      .map { Section.profileImages(order: 0, items: $0) }
    
    
    let profileDescriptions =
      elements.map { user -> [SectionItem] in
        
        var allowedItems = [
          SectionItem.text(order: 0, title: "Title", value: user.role?.role ?? ""),
          SectionItem.text(order: 1, title: "Location", value: user.location),
          SectionItem.title(order: 4, value: "About You"),
          SectionItem.textview(order: 5, value: user.description),
          SectionItem.title(order: 6, value: "Experience and Credentials"),
          SectionItem.textview(order: 7, value: user.experience_and_credentials)
        ]
        
        if(user.id == ModuleFactoryAssembler.currentUserId()) {
          allowedItems.append(SectionItem.text(order: 2, title: "Phone", value: user.phone_number))
          allowedItems.append(SectionItem.text(order: 3, title: "Email", value: user.email))
        }
        return allowedItems.sorted(by: { $0.order < $1.order })
      
      }
      .map { Section.profileDetails(order: 1, items: $0) }
    
    Observable.from([pictureDetails, profileDescriptions])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .bind(to: section)
      .disposed(by: disposeBag)
  }
  
  private func user(userId: Int) -> Observable<User> {
    return provider.rx.request(.user(userId))
      .asObservable()
      .map(User.self)
  }
}

extension ProfileViewModel {
  public enum Section {
    case profileImages(order: Int, items: [SectionItem])
    case profileDetails(order: Int, items: [SectionItem])
  }
  
  public enum SectionItem {
    case text(order: Int, title: String, value: String)
    case textview(order: Int, value: String)
    case picture(order: Int, picture: URL, value: String)
    case title(order: Int, value: String)
  }
}

extension ProfileViewModel.Section: SectionModelType {
  public typealias Items = ProfileViewModel.SectionItem
  
  public var items: [Items] {
    switch self {
    case let .profileImages(_, items):
      return items.map { $0 }
    case let .profileDetails(_, items):
      return items.map { $0 }
    }
  }
  
  public var order: Int {
    switch self {
    case let .profileImages(order, _):
      return order
    case let .profileDetails(order, _):
      return order
    }
  }
  
  public init(original: ProfileViewModel.Section, items: [Items]) {
    switch original {
    case let .profileImages(order, _):
      self = .profileImages(order: order, items: items)
    case let .profileDetails(order, _):
      self = .profileDetails(order: order, items: items)
    }
  }
}

extension ProfileViewModel.SectionItem: Equatable {
  public var order: Int {
    switch self {
    case let .text(order, _, _):
      return order
    case let .textview(order, _):
      return order
    case let .title(order, _):
      return order
    case let .picture(order, _, _):
      return order
    }
  }
  
  public static func ==(lhs: ProfileViewModel.SectionItem, rhs: ProfileViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}

