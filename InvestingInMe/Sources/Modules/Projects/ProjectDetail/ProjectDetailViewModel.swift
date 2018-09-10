//
//  ProjectDetailViewModel.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import RxDataSources
import JWTDecode

public protocol ProjectDetailViewModelProtocol {
  var items: Variable<[ProjectDetailViewModel.Section]> { get }
  var userId: Variable<Int> { get }
  var projectId: Int { get }
  var assetIndex: Variable<Int> { get }
  var checkConnection: PublishSubject<Void> { get }
  var connectionExists: PublishSubject<Bool> { get }
  var checkProjectOwner: PublishSubject<Void> { get }
  var isProjectOwner: Observable<Bool> { get }
  var loadingComplete: PublishSubject<Void> { get }
  var deleteMessageModal: PublishSubject<Void> { get }
  var feature: PublishSubject<Void> { get }
  var deleteProjectSuccess: PublishSubject<Void> { get }
  var refreshContent: PublishSubject<Void> { get }
  var featureProjectSuccess: PublishSubject<Void> { get }
  var featureProjectDenied: PublishSubject<APIError> { get }
  
  //Bottom Navigation PublishSubjects
  var deleteProject: PublishSubject<Void> { get }
  var editProject: PublishSubject<Void> { get }
  var featureProject: PublishSubject<Void> { get }
  var closeBottomNavigation: PublishSubject<Void> { get }
}

public class ProjectDetailViewModel: ProjectDetailViewModelProtocol {
  
  private let disposeBag = DisposeBag()
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  public var userId: Variable<Int> = Variable(0)
  public var projectId: Int = 0
  public var assetIndex: Variable<Int> = Variable(0)
  public var checkProjectOwner: PublishSubject<Void> = PublishSubject()
  public var loadingComplete: PublishSubject<Void> = PublishSubject()
  public var refreshContent: PublishSubject<Void> = PublishSubject()

  public var isProjectOwner: Observable<Bool> {
    return Observable.combineLatest(self.userId.asObservable(), Observable.just(ModuleFactoryAssembler.currentUserId())) { userId, currentUserId in
      return userId != currentUserId
    }
    .filter { [unowned self] _ in return self.userId.value != 0 }
  }
  
  public var items: Variable<[ProjectDetailViewModel.Section]> = Variable([])
  
  //MARK: Variables
  public var checkConnection: PublishSubject<Void> = PublishSubject()
  public var connectionExists: PublishSubject<Bool> = PublishSubject()
  
  //Delete project variables
  public var deleteMessageModal: PublishSubject<Void> = PublishSubject()
  public var feature: PublishSubject<Void> = PublishSubject()
  public var deleteProjectSuccess: PublishSubject<Void> = PublishSubject()
  public var featureProjectSuccess: PublishSubject<Void> = PublishSubject()
  public var featureProjectDenied: PublishSubject<APIError> = PublishSubject()
  
  //Bottom Navigation PublishSubjects
  public var deleteProject: PublishSubject<Void> = PublishSubject()
  public var editProject: PublishSubject<Void> = PublishSubject()
  public var featureProject: PublishSubject<Void> = PublishSubject()
  public var closeBottomNavigation: PublishSubject<Void> = PublishSubject()
  
  public init(provider: MoyaProvider<InvestingInMeAPI>, projectId: Int) {
    self.provider = provider
    self.projectId = projectId
    
    refreshContent
      .subscribe(onNext: { _ in
        self.setup()
      }).disposed(by: disposeBag)
    
    setup()
  }
  
  private func setup() {
    let project = requestProjectDetails(projectId: projectId)
      .do(onNext: { [weak self] _ in
        self?.loadingComplete.onNext(())
      })
      .materialize()
      .share()
    
    project
      .elements()
      .map { $0.user.id }
      .bind(to: self.userId)
      .disposed(by: disposeBag)
    
    deleteProject.asObservable()
      .map { [weak self] index -> Observable<Response> in
        guard let this = self else { return Observable.empty() }
        return this.deleteProject(projectId: this.projectId)
      }
      .flatMap { $0 }
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.deleteProjectSuccess.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    let sharedFeature = feature
      .flatMap { [weak self] index -> Observable<Response> in
        guard let this = self else { return Observable.empty() }
        return this.createFeatured(projectId: this.projectId)
      }
      .materialize()
      .share()
    
    sharedFeature
      .map { $0.element }
      .filterNil()
      .filter { $0.statusCode >= 299 }
      .map(APIError.self)
      .bind(to: featureProjectDenied)
      .disposed(by: disposeBag)
    
    sharedFeature
      .map { $0.element }
      .filterNil()
      .asObservable()
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.featureProjectSuccess.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    let check = project
      .elements()
      .map { $0.user.id }
      .flatMap { [unowned self] id -> Observable<Response> in
        return self.requestExistingConnection(currentUser: ModuleFactoryAssembler.currentUserId(), projectOwner: id)
      }
      .share()
    
    check
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: connectionExists)
      .disposed(by: disposeBag)
    
    let header = project.elements()
      .map { SectionItem.header(order: 0, image: $0.assets.first(where: { $0.project_icon })?.url, title: $0.name, userId: $0.user.id) }
      .map { Section(order: 0, items: [$0]) }
    
    let assets = project.elements()
      .map { SectionItem.assets(order: 0, assets: $0.assets.filter { !$0.project_icon } )}
      .map { Section(order: 1, items: [$0]) }
    
    let role = project.elements().map { project -> [SectionItem] in
      return [
        SectionItem.title(order: 0, value: "Role"),
        SectionItem.text(order: 1, value: project.role.role)
      ]
      }.map { Section(order: 2, items: $0) }
    
    let category = project.elements().map { project -> [SectionItem] in
      return [
        SectionItem.title(order: 0, value: "Category"),
        SectionItem.text(order: 1, value: project.category.type)
      ]
      }.map { Section(order: 3, items: $0) }
    
    let description = project.elements().map { project -> [SectionItem] in
      return [
        SectionItem.title(order: 0, value: "Project Description"),
        SectionItem.textview(order: 1, value: project.project_description)
      ]
      }.map { Section(order: 4, items: $0) }
    
    let needs = project.elements().map { project -> [SectionItem] in
      return [
        SectionItem.title(order: 0, value: "Project Needs"),
        SectionItem.textview(order: 1, value: project.description_needs)
      ]
      }.map { Section(order: 5, items: $0) }
    
    Observable.from([header, assets, category, role, description, needs])
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order }) }
      .observeOn(MainScheduler.instance)
      .bind(to: items)
      .disposed(by: disposeBag)
  }
  
  private func requestProjectDetails(projectId: Int) -> Observable<Project> {
    return provider.rx.request(.projectsDetail(projectId))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(Project.self)
  }
  
  private func requestExistingConnection(currentUser: Int, projectOwner: Int) -> Observable<Response> {
    return provider.rx.request(.currentConnection(currentUser, projectOwner))
      .asObservable()
  }
  
  private func deleteProject(projectId: Int) -> Observable<Response> {
    return provider.rx.request(.deleteProject(projectId))
      .asObservable()
  }
  
  private func createFeatured(projectId: Int) -> Observable<Response> {
    return provider.rx.request(.feature(projectId, Constants.duration))
      .asObservable()
  }
}

extension ProjectDetailViewModel {
  public struct Section {
    public let order: Int
    public var items: [SectionItem]
  }
  
  public enum SectionItem {
    case header(order: Int, image: URL?, title: String, userId: Int)
    case assets(order: Int, assets: [Asset])
    case text(order: Int, value: String)
    case textview(order: Int, value: String)
    case title(order: Int, value: String)
  }
}

extension ProjectDetailViewModel.Section: SectionModelType {
  public typealias Item = ProjectDetailViewModel.SectionItem
  
  public init(original: ProjectDetailViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}

extension ProjectDetailViewModel.SectionItem {
  public var order: Int {
    switch self {
    case let .header(order, _, _, _):
      return order
    case let .assets(order, _):
      return order
    case let .text(order, _):
      return order
    case let .title(order, _):
      return order
    case let .textview(order, _):
      return order
    }
  }
}

