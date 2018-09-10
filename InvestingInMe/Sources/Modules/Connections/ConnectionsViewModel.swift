//
//  ConnectionsViewModel.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-20.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya
import JWTDecode
import RxSwift
import RxDataSources
import RxOptional
import MaterialComponents

public protocol ConnectionsViewModelProtocol {
  //MARK: Variable Declarations
  //Declare required variables
  var connections: Variable<[ConnectionsViewModel.Section]> { get }
  var acceptConnection: PublishSubject<IndexPath> { get }
  var acceptConnectionSuccess: PublishSubject<Void> { get }
  var declineConnection: PublishSubject<IndexPath> { get }
  var declineConnectionSuccess: PublishSubject<Void> { get }
  var viewContact: PublishSubject<IndexPath> { get }
  var viewContactSuccess: PublishSubject<String?> { get }
  var refreshContent: PublishSubject<Void> { get }
  var refreshSuccess: PublishSubject<Void> { get }
  var itemSelected: Observable<IndexPath>! { get set }
  var acceptedConnection: PublishSubject<(title: String, message: String, email: String, phone: String)> { get }
  var receivedConnection: PublishSubject<String> { get }
  var sentConnection: PublishSubject<String> { get }
  var isConnectionsEmpty: Observable<Bool> { get }
  var loadingComplete: PublishSubject<Void> { get }
  
  func bindButtons()
  var userId: Int { get }
}

public class ConnectionsViewModel: ConnectionsViewModelProtocol {
  
  //MARK: Variable Initializations
  //Initialize the provider with our API
  private let provider: MoyaProvider<InvestingInMeAPI>!
  
  //Initialize the variable to hold our Connections
  public var connections: Variable<[ConnectionsViewModel.Section]> = Variable([])
  
  //Initialize the various Connection types and possibilites
  public var acceptConnection: PublishSubject<IndexPath> = PublishSubject()
  public var acceptConnectionSuccess: PublishSubject<Void> = PublishSubject()
  public var declineConnection: PublishSubject<IndexPath> = PublishSubject()
  public var declineConnectionSuccess: PublishSubject<Void> = PublishSubject()
  public var viewContact: PublishSubject<IndexPath> = PublishSubject()
  public var viewContactSuccess: PublishSubject<String?> = PublishSubject()
  public var itemSelected: Observable<IndexPath>!
  public var acceptedConnection: PublishSubject<(title: String, message: String, email: String, phone: String)> = PublishSubject()
  public var receivedConnection: PublishSubject<String> = PublishSubject()
  public var sentConnection: PublishSubject<String> = PublishSubject()
  
  //Initialize the refresh variables
  public var refreshContent: PublishSubject<Void> = PublishSubject()
  public var refreshSuccess: PublishSubject<Void> = PublishSubject()
  
  //Initializer the loading icon
  public var loadingComplete: PublishSubject<Void> = PublishSubject()
  
  //Observables
  public var isConnectionsEmpty: Observable<Bool> {
    return connections.asObservable()
      .map { $0.isEmpty }
      .skip(1)
  }
  
  //Declare the user id
  public var userId: Int

  //Declare the DisposeBag
  private let disposeBag = DisposeBag()
  
  //Setup the initializer refreshing the Content
  public init(provider: MoyaProvider<InvestingInMeAPI>, userId: Int) {
    self.provider = provider
    self.userId = userId

    setupConnections()
    
    //Setup our refreshContent to call the setup function
    refreshContent
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.setupConnections()
        this.refreshSuccess.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    declineConnection
      .map { [weak self] index in return self?.connections.value[index.section].items[index.row].connectionId }
      .filterNil()
      .flatMap { [unowned self] id in return self.deleteConnection(connectionId: id) }
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .subscribe (onNext: { _ in
        self.declineConnectionSuccess.on(.next(()))
        self.refreshContent.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    acceptConnection
      .map { [weak self] index in return self?.connections.value[index.section].items[index.row].connectionId }
      .filterNil()
      .flatMap { [unowned self] id in return self.updateConnection(id: id, accepted: true) }
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .subscribe (onNext: { _ in
        self.acceptConnectionSuccess.on(.next(()))
        self.refreshContent.on(.next(()))
      })
      .disposed(by: disposeBag)
    
  }
  
  public func bindButtons() {
    itemSelected
      .map { [weak self] index in
        return self?.connections.value[index.section].items[index.row]
      }
      .filterNil()
      .subscribe(onNext: { [weak self] row in
        guard let this = self else { return }
        switch row {
        case let .acceptedConnections(_, _, _, _, userEmail, userPhone, _, _):
          // Check for valid phone and email
          let emailAddress = (userEmail.isEmpty) ? "No Email Address" : userEmail
          let phoneNumber = (userPhone.isEmpty) ? "No Phone Number" : userPhone
          
          let title = "Contact Information"
          let message = "User Email: \(userEmail) \nUser Phone: \(phoneNumber)"
          
          let data: (title: String, message: String, email: String, phone: String) = (
            title,
            message,
            emailAddress,
            phoneNumber
          )
          
          this.acceptedConnection.onNext(data)
        case let .receivedConnections(_, _, _, _, message, _):
          this.receivedConnection.onNext(message.isEmpty ? "No message was given." : message)
        case let .sentConnections(_, _, _, _, message, _):
          this.sentConnection.onNext(message.isEmpty ? "No message was given." : message)
        }
      })
    .disposed(by: disposeBag)
  }
  
  //MARK: Setup
  func setupConnections() {

    //Get all connections
    let allConnections = self.allConnections()
      .do(onNext: { [weak self] _ in
        self?.loadingComplete.onNext(())
      })
      .materialize()
      .map { $0.element }
      .filterNil()
      .share()

    //Filter all connections where the current user is not the invitee - A sent connection request
    //Map the sent connections into sentConnection SectionItems
    let allReceivedConnections = allConnections
      .map { connections in
        return connections.filter { connection in
          return connection.invitee.id == ModuleFactoryAssembler.currentUserId() && !connection.accepted
        }
      }
      .map { connections in
        return connections.enumerated().map { data in
          return SectionItem.receivedConnections(
            order: data.offset,
            userImage: data.element.inviter.picture,
            userName: data.element.inviter.name,
            userRole: data.element.inviter.role,
            message: data.element.message,
            connectionId: data.element.id
          )
        }
      }
      .map { Section.receivedConnectionsSection(order: 0, title: "Received Connections", items: $0, backgroundColor: MDCPalette.lightBlue.tint50) }
    
    let allSentConnections = allConnections
      .map { connections in
        return connections.filter { connection in
          return connection.inviter.id == ModuleFactoryAssembler.currentUserId() && !connection.accepted
        }
      }
      .map { connections in
        return connections.enumerated().map { connection in
          return SectionItem.sentConnections(
            order: connection.offset,
            userImage: connection.element.invitee.picture,
            userName: connection.element.invitee.name,
            userRole: connection.element.invitee.role,
            message: connection.element.message,
            connectionId: connection.element.id
          )
        }
      }
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .map { Section.sentConnectionsSection(order: 1, title: "Sent Connections", items: $0, backgroundColor: MDCPalette.red.tint50) }
    
    //Filter all connections where the current user is the invitee - A received connection request
    //Map the received connections into receivedConnection SectionItems
    //Filter all connections to find all currently accepted connections
    //Map the accepted connections into acceptedConnection SectionItems
    let allAcceptedConnections = allConnections
      .map { connections in
        return connections.filter { connection in
          return
            (connection.invitee.id == ModuleFactoryAssembler.currentUserId() &&
             connection.accepted) ||
            (connection.inviter.id == ModuleFactoryAssembler.currentUserId() &&
             connection.accepted)
        }
      }
      .map { connections in
        return connections.enumerated().map { data -> ConnectionsViewModel.SectionItem in
          if data.element.invitee.id == ModuleFactoryAssembler.currentUserId() {
            return SectionItem.acceptedConnections(
              order: data.offset,
              userImage: data.element.inviter.picture,
              userName: data.element.inviter.name,
              userRole: data.element.inviter.role,
              userEmail: data.element.inviter.email,
              userPhone: data.element.inviter.phone_number,
              userId: data.element.inviter.id,
              connectionId: data.element.id
            )
          } else {
            return SectionItem.acceptedConnections(
              order: data.offset,
              userImage: data.element.invitee.picture,
              userName: data.element.invitee.name,
              userRole: data.element.invitee.role,
              userEmail: data.element.invitee.email,
              userPhone: data.element.invitee.phone_number,
              userId: data.element.invitee.id,
              connectionId: data.element.id
            )
          }
        }
      }
      .map { Section.acceptedConnectionsSection(order: 2, title: "Accepted Connections", items: $0, backgroundColor: MDCPalette.lightGreen.tint50) }
    
    //Add the Sections to the Connection item so we can use it in the ViewController
    Observable.from([allReceivedConnections, allSentConnections, allAcceptedConnections])
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order } )}
      .bind(to: connections)
      .disposed(by: disposeBag)
  }
  
  //MARK: All Connections
  private func allConnections() -> Observable<[Connection]> {
    //Return an obervable array of all connections
    return provider.rx.request(.allConnections(userId))
      .asObservable()
      .map([Connection].self)
  }
  
  //MARK: Delete Connection
  public func deleteConnection(connectionId id: Int) -> Observable<Response> {
    return provider.rx.request(.deleteConnection(id))
      .asObservable()
  }
  
  //MARK: Update Connection
  public func updateConnection(id: Int, accepted: Bool) -> Observable<Response> {
    return provider.rx.request(.updateConnection(id, accepted))
      .asObservable()
  }
}

//MARK: ConnectionsModel
extension ConnectionsViewModel {
  
  //Setup the different sections of the Connections Page
  public enum Section {
    case receivedConnectionsSection(order: Int, title: String, items: [SectionItem], backgroundColor: UIColor)
    case sentConnectionsSection(order: Int, title: String, items: [SectionItem], backgroundColor: UIColor)
    case acceptedConnectionsSection(order: Int, title: String, items: [SectionItem], backgroundColor: UIColor)
  }
  
  //Declare the different connection section items
  public enum SectionItem {
    case receivedConnections(order: Int, userImage: URL, userName: String, userRole: Role?, message: String, connectionId: Int)
    case acceptedConnections(order: Int, userImage: URL, userName: String, userRole: Role?, userEmail: String, userPhone: String, userId: Int, connectionId: Int)
    case sentConnections(order: Int, userImage: URL, userName: String, userRole: Role?, message: String, connectionId: Int)
  }
}

//MARK: SectionModelType - RxDataSources
extension ConnectionsViewModel.Section: SectionModelType {
  
  //Seclare the items for the Connection section item
  public typealias Item = ConnectionsViewModel.SectionItem
  
  public init(original: ConnectionsViewModel.Section, items: [Item]) {
    switch original {
    case let .receivedConnectionsSection(order, title, _, backgroundColor):
      self = .receivedConnectionsSection(order: order, title: title, items: items, backgroundColor: backgroundColor)
    case let .sentConnectionsSection(order, title, _, backgroundColor):
      self = .sentConnectionsSection(order: order, title: title, items: items, backgroundColor: backgroundColor)
    case let .acceptedConnectionsSection(order, title, _, backgroundColor):
      self = .acceptedConnectionsSection(order: order, title: title, items: items, backgroundColor: backgroundColor)
    }
  }
  
  public var items: [Item] {
    switch self {
      case let .receivedConnectionsSection(_, _, items, _):
        return items.map { $0 }
      case let .sentConnectionsSection(_, _, items, _):
        return items.map { $0 }
      case let .acceptedConnectionsSection(_, _, items, _):
        return items.map { $0 }
    }
  }
  
  //Setup the ordering for the different sections
  public var order: Int {
    switch self {
    case let .receivedConnectionsSection(order, _, _, _):
      return order
    case let .sentConnectionsSection(order, _, _, _):
      return order
    case let .acceptedConnectionsSection(order, _, _, _):
      return order
    }
  }
  
  public var title: String {
    switch self {
    case let .receivedConnectionsSection(_, title, _, _):
      return title
    case let .sentConnectionsSection(_, title, _, _):
      return title
    case let .acceptedConnectionsSection(_, title, _, _):
      return title
    }
  }
  
  public var backgroundColor: UIColor {
    switch self {
    case let .receivedConnectionsSection(_, _, _, backgroundColor):
      return backgroundColor
    case let .sentConnectionsSection(_, _, _, backgroundColor):
      return backgroundColor
    case let .acceptedConnectionsSection(_, _, _, backgroundColor):
      return backgroundColor
    }
  }
}

//MARK: Connections Equatable
extension ConnectionsViewModel.SectionItem: Equatable {
  
  //Setup the ordering for each SectionItem
  public var order: Int {
    switch self {
    case .receivedConnections(let order, _, _, _, _, _):
      return order
    case .acceptedConnections(let order, _, _, _, _, _, _, _):
      return order
    case .sentConnections(let order, _, _, _, _, _):
      return order
    }
  }
  
  public var connectionId: Int {
    switch self {
    case .receivedConnections(_, _, _, _, _, let connectionId):
      return connectionId
    case .acceptedConnections(_, _, _, _, _, _, _, let connectionId):
      return connectionId
    case .sentConnections(_, _, _, _, _, let connectionId):
      return connectionId
    }
  }
  
  //Auto-implemented method to ensure SectionItems conform to the Equatable protocol
  public static func ==(lhs: ConnectionsViewModel.SectionItem, rhs: ConnectionsViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}
