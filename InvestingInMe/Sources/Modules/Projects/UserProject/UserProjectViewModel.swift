//
//  UserProjectViewModel.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxOptional
import Moya
import JWTDecode

public protocol UserProjectViewModelProtocol {
  var items: Variable<[UserProjectViewModel.SectionItem]> { get }
  var refreshContent: PublishSubject<Void> { get }
  var refreshSuccess: PublishSubject<Void> { get }
  var deleteProject: PublishSubject<IndexPath> { get }
  var deleteProjectSuccess: PublishSubject<Void> { get }
  var isItemsEmpty: Observable<Bool> { get }
  var loadingComplete: PublishSubject<Void> { get }
}

public class UserProjectViewModel: UserProjectViewModelProtocol {
  
  private let disposeBag = DisposeBag()
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  public var items: Variable<[UserProjectViewModel.SectionItem]> = Variable([])
  
  //Initialize the refresh variables
  public var refreshContent: PublishSubject<Void> = PublishSubject()
  public var refreshSuccess: PublishSubject<Void> = PublishSubject()
  
  //Delete project variables
  public var deleteProject: PublishSubject<IndexPath> = PublishSubject()
  public var deleteProjectSuccess: PublishSubject<Void> = PublishSubject()
  
  // MARK: Observables
  public var isItemsEmpty: Observable<Bool> {
    return items.asObservable()
      .map { $0.isEmpty }
      .skip(1)
  }
  
  //Loading Indicator
  public var loadingComplete: PublishSubject<Void> = PublishSubject()
  
  public init(provider: MoyaProvider<InvestingInMeAPI>) {
    self.provider = provider
    
    setup()
    
    //Setup our refreshContent to call the setup function
    refreshContent
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.setup()
        this.refreshSuccess.on(.next(()))
      })
      .disposed(by: disposeBag)
    
    deleteProject.asObservable()
      .map { [weak self] index -> Observable<Response> in
        guard let this = self else { return Observable.empty() }
        let project = this.items.value[index.row]
        return this.deleteProject(projectId: project.id)
      }
      .flatMap { $0 }
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.deleteProjectSuccess.on(.next(()))
        this.refreshContent.on(.next(()))
      })
      .disposed(by: disposeBag)
  }
  
  private func setup() {
    let userProjects = requestUserProjects()
      .do(onNext: { [weak self] _ in
        self?.loadingComplete.onNext(())
      })
      .materialize()
      .share()
    
    userProjects
      .elements()
      .map { $0.map { SectionItem(id: $0.id, title: $0.name, description: $0.project_description, image: $0.assets.first(where: { $0.project_icon })?.url)}}
      .bind(to: items)
      .disposed(by: disposeBag)
  }
  
  private func requestUserProjects() -> Observable<[Project]> {
    let token: String = UserDefaults.standard.object(forKey: "token") as! String
    let jwt = try? decode(jwt: token)
    let user_id: Int = jwt!.body["user_id"] as! Int
    return provider.rx.request(.userProjects(user_id))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map([Project].self)
  }
  
  private func deleteProject(projectId: Int) -> Observable<Response> {
    return provider.rx.request(.deleteProject(projectId))
      .asObservable()
  }
}

extension UserProjectViewModel {
  public struct SectionItem {
    public let id: Int
    public let title: String
    public let description: String
    public let image: URL?
  }
}

