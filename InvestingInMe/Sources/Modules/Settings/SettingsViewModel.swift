//
//  SettingsViewModel.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-19.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import GoogleSignIn
import MessageUI
import Moya

public protocol SettingsViewModelProtocol {
  var items: Variable<[SettingsViewModel.Section]> { get }
  var itemSelected: Observable<IndexPath>! { get set }
  var logoutSuccess: PublishSubject<Void> { get }
  var disconnectSuccess: PublishSubject<Void> { get }
  var canSendMail: PublishSubject<Void> { get }
  var onUpdatePushNotifications: PublishSubject<Bool> { get }
  var onURLSend: PublishSubject<(String, URL)> { get }
  var sendEmail: PublishSubject<(String, [String], String)> { get }
  var onSettingsSend: PublishSubject<Void> { get }
  func bindCell()
}

public class SettingsViewModel: SettingsViewModelProtocol {
  // MARK: Properties
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  // MARK: Variables
  public var items: Variable<[SettingsViewModel.Section]> = Variable([])
  
  // MARK: Observables
  public var itemSelected: Observable<IndexPath>!
  
  // MARK: PublishSubjects
  public var logoutSuccess: PublishSubject<Void> = PublishSubject()
  public var disconnectSuccess: PublishSubject<Void> = PublishSubject()
  public var canSendMail: PublishSubject<Void> = PublishSubject()
  public var sendEmail: PublishSubject<(String, [String], String)> = PublishSubject()
  public var onUpdatePushNotifications: PublishSubject<Bool> = PublishSubject()
  public var onURLSend: PublishSubject<(String, URL)> = PublishSubject()
  public var onSettingsSend: PublishSubject<Void> = PublishSubject()
  
  private let disposeBag = DisposeBag()
  
  public init(provider: MoyaProvider<InvestingInMeAPI>) {
    self.provider = provider
    
    setup()
    
    onUpdatePushNotifications
      .asObservable()
      .map { isOn -> String? in
        if isOn {
          return UserDefaults.standard.string(forKey: "player_id")
        }
        return ""
      }
      .filterNil()
      .flatMap { [unowned self] playerId in return self.updateNotification(id: ModuleFactoryAssembler.currentUserId(), playerId: playerId) }
      .materialize()
      .map { $0.element }
      .filterNil()
      .map { $0.player_id }
      .map { playerId -> Bool in
        if playerId?.isEmpty ?? true {
          return false
        }
        return true
      }
      .subscribe(onNext: { [weak self] isOn in
        guard let this = self else { return }
        switch this.items.value[0].items[2] {
        case let .pushNotifications(order, title, _):
          let newItem = SectionItem.pushNotifications(order: order, title: title, isOn: isOn)
          this.items.value[0].items[2] = newItem
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func setup() {
    let app: [SettingsViewModel.SectionItem] = [
      SectionItem.version(order: 0, version: Bundle.versionNumber ?? ""),
      SectionItem.build(order: 1, build: Bundle.buildNumber ?? ""),
      SectionItem.report(order: 2, title: "Report a Bug"),
      SectionItem.url(order: 3, title: "Terms of Service", url: URL(string: Constants.TERMS_OF_SERVICE_URL)!),
      SectionItem.url(order: 4, title: "Privacy Policy", url: URL(string: Constants.PRIVACY_POLICY_URL)!),
      SectionItem.license(order: 5, title: "Licenses We Use")
    ].sorted(by: { $0.order < $1.order })
    
    let account: [SettingsViewModel.SectionItem] = [
      SectionItem.disconnect(order: 0, title: "Disconnect Google App"),
      SectionItem.logout(order: 1, title: "Log out")
    ].sorted(by: { $0.order < $1.order })
    
    let accountSection = requestUser(id: ModuleFactoryAssembler.currentUserId())
      .materialize()
      .map { $0.element }
      .filterNil()
      .map { $0.player_id }
      .map { playerId -> SectionItem in
        if playerId?.isEmpty ?? true {
          return SectionItem.pushNotifications(order: 2, title: "Push Notifications", isOn: false)
        }
        return SectionItem.pushNotifications(order: 2, title: "Push Notifications", isOn: true)
      }
      .map { item -> Section in
        var newApp = account
        newApp.append(item)
        return Section(order: 0, title: "Account Information", items: newApp)
      }
    
    let appSection = Observable.just(app).map { Section(order: 1, title: "App Information", items: $0) }
    
    Observable.from([appSection, accountSection])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .bind(to: items)
      .disposed(by: disposeBag)
  }
  
  public func bindCell() {
    //: TODO - This needs to be refactored for constant log ins after
    itemSelected
      .map { [weak self] index in return self?.items.value[index.section].items[index.row] }
      .filterNil()
      .subscribe(onNext: { [weak self] item in
        guard let this = self else { return }
        // check if it's item
        switch item {
        case .disconnect:
          if !GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
          }
          this.disconnectSuccess.onNext(())
          break
        case .logout:
          // attempt to log out
          this.logoutSuccess.onNext(())
          break
        case .report:
          if !MFMailComposeViewController.canSendMail() {
            this.canSendMail.on(.next(()))
          } else {
            let recipient = "johnny.nguyen39@stclairconnect.ca"
            let cc: [String] = ["jarrodmaeckeler@gmail.com", "liam.goodwin1@stclairconnect.ca"]
            let subject = "InvestingInMe - Bug Report"
            this.sendEmail.onNext((recipient, cc, subject))
          }
        case let .url(_, title, url):
          this.onURLSend.onNext((title, url))
        case .license:
          this.onSettingsSend.onNext(())
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func requestUser(id: Int) -> Observable<User> {
    return provider.rx.request(.user(id))
      .asObservable()
      .map(User.self)
  }
  
  private func updateNotification(id: Int, playerId: String) -> Observable<User> {
    return provider.rx.request(.updateUserNotification(id, playerId))
      .asObservable()
      .map(User.self)
  }
}

extension SettingsViewModel {
  public struct Section {
    public let order: Int
    public let title: String
    public var items: [SectionItem]
  }
  
  public enum SectionItem {
    case disconnect(order: Int, title: String)
    case logout(order: Int, title: String)
    case pushNotifications(order: Int, title: String, isOn: Bool)
    case version(order: Int, version: String)
    case build(order: Int, build: String)
    case report(order: Int, title: String)
    case url(order: Int, title: String, url: URL)
    case license(order: Int, title: String)
  }
}

extension SettingsViewModel.Section: SectionModelType {
  public typealias Item = SettingsViewModel.SectionItem
  
  public init(original: SettingsViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}

extension SettingsViewModel.SectionItem {
  public var order: Int {
    switch self {
    case let .pushNotifications(order, _, _):
      return order
    case let .report(order, _):
      return order
    case let .build(order, _):
      return order
    case let .version(order, _):
      return order
    case let .disconnect(order, _):
      return order
    case let .logout(order, _):
      return order
    case let .url(order, _, _):
      return order
    case let .license(order, _):
      return order
    }
  }
}

extension SettingsViewModel.SectionItem: Equatable {
  public static func ==(lhs: SettingsViewModel.SectionItem, rhs: SettingsViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}

extension SettingsViewModel.Section: Equatable {
  public static func ==(lhs: SettingsViewModel.Section, rhs: SettingsViewModel.Section) -> Bool {
    return lhs.order == rhs.order
  }
}
