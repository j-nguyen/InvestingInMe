//
//  FeaturedProjectViewModel.swift
//  InvestingInMe
//
//  Created by jarrod maeckeler on 2018-02-08.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import Moya

public protocol FeaturedProjectViewModelProtocol {
  var items: Variable<[FeaturedProjectViewModel.SectionItem]> { get }
  var isItemsEmpty: Observable<Bool> { get }
  var loadingComplete: PublishSubject<Void> { get }
}

public class FeaturedProjectViewModel: FeaturedProjectViewModelProtocol {
  
  private let disposeBag = DisposeBag()
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  // MARK: Variables
  public var items: Variable<[FeaturedProjectViewModel.SectionItem]> = Variable([])
  
  // MARK: Observables
  public var isItemsEmpty: Observable<Bool> {
    return items.asObservable().map { $0.isEmpty }.skip(1)
  }
  
  //Determine if loading is complete
  public var loadingComplete: PublishSubject<Void> = PublishSubject()
  
  public init(provider: MoyaProvider<InvestingInMeAPI>) {
    self.provider = provider
    
    let results = requestFeaturedProjects()
      .do(onNext: { [weak self] _ in
        self?.loadingComplete.onNext(())
      })
      .materialize()
      .share()
    
    results
      .elements()
      .map { featuredProjects in
        return featuredProjects.map { featuredProject in
          return SectionItem(
            id: featuredProject.project.id,
            title: featuredProject.project.name,
            category: "Category: \(featuredProject.project.category.type)",
            role: "Looking For: \(featuredProject.project.role.role)",
            description: featuredProject.project.project_description,
            image: featuredProject.project.assets.first(where: { $0.project_icon })!.url
          )
        }
      }
      .bind(to: items)
      .disposed(by: disposeBag)
  }
  
  private func requestFeaturedProjects() -> Observable<[FeaturedProject]> {
    return provider.rx.request(.featuredProjects)
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map([FeaturedProject].self)
  }
}

extension FeaturedProjectViewModel {
  public struct SectionItem {
    public let id: Int
    public let title: String
    public let category: String
    public let role: String
    public let description: String
    public let image: URL
  }
}
