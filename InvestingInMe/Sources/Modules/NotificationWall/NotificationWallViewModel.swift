//
//  NotificationWallViewModel.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-03-31.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import Moya

public protocol NotificationWallViewModelProtocol {
  var notifications: Variable<[Notification]> { get }
  var isItemsEmpty: Observable<Bool> { get }
  var onRefresh: PublishSubject<Void> { get }
  var onRefreshSuccess: PublishSubject<Void> { get }
}

public class NotificationWallViewModel: NotificationWallViewModelProtocol {
  // MARK: Properties
  private let disposeBag = DisposeBag()
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  // MARK: PublishSubjects
  public var onRefresh: PublishSubject<Void> = PublishSubject()
  public var onRefreshSuccess: PublishSubject<Void> = PublishSubject()
  
  // MARK: Variables
  public var notifications: Variable<[Notification]> = Variable([])
  
  public var isItemsEmpty: Observable<Bool> {
    return notifications.asObservable().skip(1).map { $0.isEmpty }
  }
  
  public init(provider: MoyaProvider<InvestingInMeAPI>) {
    self.provider = provider
    
    onRefresh
      .asObservable()
      .subscribe(onNext: { [weak self] in
        self?.setup()
        self?.onRefreshSuccess.onNext(())
      }).disposed(by: disposeBag)
    
    setup()
  }
  
  private func setup() {
    let sharedNotifications = requestNotifications()
      .materialize()
      .share()
    
    sharedNotifications
      .map { $0.element }
      .map { $0?.sorted(by: { $0.created_at > $1.created_at }) }
      .filterNil()
      .bind(to: notifications)
      .disposed(by: disposeBag)
  }
  
  private func requestNotifications() -> Observable<[Notification]> {
    return provider.rx.request(.notifications)
      .asObservable()
      .map([Notification].self, using: JSONDecoder.Decode)
  }
}

