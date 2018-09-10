//
//  SendMessageViewModel.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Foundation
import RxSwift
import RxOptional
import RxDataSources
import Moya
import JWTDecode

public protocol SendMessageViewModelProtocol {
  
  //Declare the Section for the SendMessageViewModel
  var section: Variable<[SendMessageViewModel.Section]> { get }
  
  //Declare the fields for the Message View
  var recipientName: PublishSubject<String> { get }
  var recipientId: PublishSubject<Int> { get }
  var message: Variable<String> { get }
  
  //Declare the various Send button Verifications
  var sendButtonTap: Observable<Void>! { get set }
  var sendButtonSuccess: PublishSubject<Bool> { get }
  var sendButtonFail: PublishSubject<APIError> { get }
  
  //Declare the bind Send Button method
  func bindButtons()
}

public class SendMessageViewModel: SendMessageViewModelProtocol {
  
  //MARK: Variable Declarations
  private let user_id: Int!
  private let currentUser: Int!
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  //Instantiate Variables for the View
  public var recipientName: PublishSubject<String> = PublishSubject()
  public var recipientId: PublishSubject<Int> = PublishSubject()
  public var message: Variable<String> = Variable("")
  
  //Instantiate the Submit Button and Verifications
  public var sendButtonTap: Observable<Void>!
  public var sendButtonSuccess: PublishSubject<Bool> = PublishSubject()
  public var sendButtonFail: PublishSubject<APIError> = PublishSubject()
  
  //Declare the Section Variable
  public var section: Variable<[SendMessageViewModel.Section]> = Variable([])
  
  //MARK: Dispose
  private let disposeBag: DisposeBag = DisposeBag()
  
  //Declare the public initializer
  public init(provider: MoyaProvider<InvestingInMeAPI>, userId: Int) {
    self.provider = provider
    self.user_id = userId
    self.currentUser = ModuleFactoryAssembler.currentUserId()
    
    setup()
  }
  
  //MARK: Setup
  private func setup() {
    
    //Request the recipient
    let recipientUser = user(user_id: user_id)
      .materialize()
      .share()
    
    //Map valid elements from the recipient
    let elements = recipientUser
      .map { $0.element }
      .filterNil()
      .share()
    
    //Create the elements of the SendMessage View
    let recipientSection = elements.map {
      SectionItem.recipient(order: 0, id: $0.id, name: $0.name) }
      .map { Section.recipient(order: 0, item: [$0])}
    let messageSection = elements.map { _ in
      SectionItem.message(order: 1, message: "Enter a message...") }
      .map { Section.message(order: 1, item: [$0])}
    
    Observable.from([recipientSection, messageSection])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .catchErrorJustReturn([])
      .bind(to: section)
      .disposed(by: disposeBag)
  }
  
  //Declare the bindButtons Function
  public func bindButtons() {
    
    //When send button is tapped it will take all parameters from the SendMessage page and attempt to submit the request
    let btn = sendButtonTap
      .flatMap { [weak self] _ -> Observable<Response> in
        guard let this = self else { fatalError() }
        return this.createConnection(inviterId: this.currentUser, inviteeId: this.user_id, accepted: false, message: this.message.value)
      }
      .share()
    
    //Check if the Create Connection failed
    btn
      .filter { $0.statusCode >= 299 }
      .map(APIError.self)
      .bind(to: sendButtonFail)
      .disposed(by: disposeBag)
    
    //Check if the Create Connection was successful
    btn
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: sendButtonSuccess)
      .disposed(by: disposeBag)
  }
  
  //Get the requested user from the API
  private func user(user_id: Int) -> Observable<User> {
    return provider.rx.request(.user(user_id))
      .asObservable()
      .map(User.self)
  }
  
  //Submit the create connection from the API
  private func createConnection(inviterId: Int, inviteeId: Int, accepted: Bool, message: String) -> Observable<Response> {
    return provider.rx.request(.createConnection(inviterId, inviteeId, accepted, message))
      .asObservable()
  }
}

extension SendMessageViewModel {
  
  public enum Section {
    case recipient(order: Int, item: [SectionItem])
    case message(order: Int, item: [SectionItem])
  }
  
  public enum SectionItem {
    case recipient(order: Int, id: Int, name: String)
    case message(order: Int, message: String)
  }
}

//MARK: SectionModelType - RxDataSources
extension SendMessageViewModel.Section: SectionModelType {
  
  //Declare the Item for the SendMessage SectionItem
  public typealias Items = SendMessageViewModel.SectionItem
  
  public var items: [Items] {
    switch self {
    case let .recipient(_, items):
      return items.map { $0 }
    case let .message(_, items):
      return items.map { $0 }
    }
  }
  
  //Setup the ordering for the different sections
  public var order: Int {
    switch self {
    case let .recipient(order, _):
      return order
    case let .message(order, _):
      return order
    }
  }
  
  public init(original: SendMessageViewModel.Section, items: [Items]) {
    switch original {
    case let .recipient(order, _):
      self = .recipient(order: order, item: items)
    case let .message(order, _):
      self = .message(order: order, item: items)
    }
  }
}
