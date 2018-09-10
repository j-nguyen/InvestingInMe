//
//  AllProjectViewModel.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-22.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import Moya

public protocol AllProjectViewModelProtocol {
  var items: Variable<[AllProjectViewModel.SectionItem]> { get }
  var refreshContent: PublishSubject<Void> { get }
  var refreshSuccess: PublishSubject<Void> { get }
  var loadingComplete: PublishSubject<Void> { get }
}

public class AllProjectViewModel: AllProjectViewModelProtocol {
  
  private let disposeBag = DisposeBag()
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  public var items: Variable<[AllProjectViewModel.SectionItem]> = Variable([])
  
  //Initialize the refresh variables
  public var refreshContent: PublishSubject<Void> = PublishSubject()
  public var refreshSuccess: PublishSubject<Void> = PublishSubject()
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

  }
  
  private func setup() {
    let featuredProjects = requestFeaturedProjects()
      .do(onNext: { [weak self] _ in
        self?.loadingComplete.onNext(())
      })
      .materialize()
      .share()
    
    featuredProjects
      .elements()
      .map{ $0.map{ SectionItem(id: $0.id, title: $0.name, category: $0.category.type, role: $0.role.role, image: $0.assets.first(where: { $0.project_icon })?.url)}}
      .bind(to: items)
      .disposed(by: disposeBag)
  }
  
  private func requestFeaturedProjects() -> Observable<[Project]> {
    return provider.rx.request(.allProjects(nil, nil, nil))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map([Project].self)
  }
}

extension AllProjectViewModel {
  public struct SectionItem {
    public let id: Int
    public let title: String
    public let category: String
    public let role: String
    public let image: URL?
  }
}

