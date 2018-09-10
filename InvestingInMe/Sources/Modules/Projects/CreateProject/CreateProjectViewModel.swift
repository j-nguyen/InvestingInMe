//
//  CreateProjectViewModel.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-03-03.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxDataSources
import JWTDecode

public protocol CreateProjectViewModelProtocol {
  var items: Variable<[CreateProjectViewModel.Section]> { get }
  var itemSelected: Observable<IndexPath>! { get set }
  var doneSelected: Observable<Void>! { get set }
  var iconClicked: PublishSubject<Void> { get }
  var iconSetImageURL: PublishSubject<URL> { get }
  var tableIndex: Variable<IndexPath?> { get }
  // events
  var onCreateProjectSuccess: PublishSubject<Void> { get }
  var onScreenshotSetImages: PublishSubject<[UIImage]> { get }
  var onCreateIconImage: PublishSubject<Bool> { get }
  var onDecideIconImage: PublishSubject<Void> { get }
  var onDeclinedImage: PublishSubject<Void> { get }
  var onError: PublishSubject<APIError> { get }
  var uploadingComplete: PublishSubject<Void> { get }
  var showLoader: PublishSubject<Void> { get }
  // data items
  var iconImage: Variable<Data?> { get }
  var screenshotImages: Variable<[Data]?> { get }
  var name: Variable<String?> { get }
  var description: Variable<String?> { get }
  var category: Variable<Category?> { get }
  var role: Variable<Role?> { get }
  var needs: Variable<String?> { get }
  var isButtonEnabled: Observable<Bool> { get }
  var projectId: Variable<Int?> { get }
  // events
  func bindButtons()
}

public class CreateProjectViewModel: CreateProjectViewModelProtocol {
  // MARK: Provider
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  public var items: Variable<[CreateProjectViewModel.Section]> = Variable([])
  public var itemSelected: Observable<IndexPath>!
  public var doneSelected: Observable<Void>!
  
  public var iconClicked: PublishSubject<Void> = PublishSubject()
  public var iconSetImageURL: PublishSubject<URL> = PublishSubject()
  public var onScreenshotSetImages: PublishSubject<[UIImage]> = PublishSubject()
  public var tableIndex: Variable<IndexPath?> = Variable(nil)
  public var onCreateProjectSuccess: PublishSubject<Void> = PublishSubject()
  public var onCreateIconImage: PublishSubject<Bool> = PublishSubject()
  public var onDecideIconImage: PublishSubject<Void> = PublishSubject()
  public var onDeclinedImage: PublishSubject<Void> = PublishSubject()
  public var uploadingComplete: PublishSubject<Void> = PublishSubject()
  public var showLoader: PublishSubject<Void> = PublishSubject()
  public var onError: PublishSubject<APIError> = PublishSubject()

  // form data for creating project
  public var iconImage: Variable<Data?> = Variable(nil)
  public var screenshotImages: Variable<[Data]?> = Variable(nil)
  public var name: Variable<String?> = Variable(nil)
  public var description: Variable<String?> = Variable(nil)
  public var category: Variable<Category?> = Variable(nil)
  public var role: Variable<Role?> = Variable(nil)
  public var needs: Variable<String?> = Variable(nil)
  public var projectId: Variable<Int?> = Variable(nil)
  public var success: Variable<Bool> = Variable(false)
  
  // MARK: Observables
  public var isButtonEnabled: Observable<Bool> {
    return Observable.combineLatest(
      screenshotImages.asObservable(), name.asObservable(), description.asObservable(),
      category.asObservable(), role.asObservable(), needs.asObservable())
    { screenshots, name, desc, category, role, needs in
      return screenshots != nil && name != nil && category != nil && role != nil && needs?.isNotEmpty ?? false && desc?.isNotEmpty ?? false
    }
  }
  
  private var screenshotIndex = Variable(0)
  
  private let disposeBag = DisposeBag()
  
  public init(provider: MoyaProvider<InvestingInMeAPI>) {
    self.provider = provider
    
    setup()
    setupCellClicks()
  }
  
  /// The main setup
  private func setup() {
    // MARK: Project Info
    let projectInfoList: [SectionItem] = [
      .icon(order: 0, title: "Icon", imageURL: URL(string: Constants.placeholderImage)! ),
      .name(order: 1, title: "Project Name", placeholder: "Enter your project name")
    ].sorted(by: { $0.order < $1.order })
    
    let projectInfo = Observable.just(Section(order: 0, items: projectInfoList))
    
    // MARK: Project Description
    let projectDesc = Observable.just(SectionItem.description(order: 1, placeholder: "Enter in your project description!"))
      .map { item in
        return [
          SectionItem.title(order: 0, title: "Project Description"),
          item
        ].sorted(by: { first, second -> Bool in first.order < second.order})
      }
      .map { Section(order: 1, items: $0) }
    
    // MARK: Categories
    let categories = self.requestCategories()
      .map { SectionItem.category(order: 0, title: "Categories", categories: $0) }
      .map { Section(order: 2, items: [$0]) }
    
    // MARK: Screenshots
    let screenshotItem = [
      SectionItem.screenshotTitle(order: 0, title: "Screenshots"),
      SectionItem.screenshots(order: 0, assets: [])
    ]
    
    let screenshots = Observable.just(Section(order: 3, items: screenshotItem))
    
    // MARK: Roles
    let role = self.requestRoles()
      .map { SectionItem.role(order: 0, title: "Roles", roles: $0) }
      .map { Section(order: 4, items: [$0]) }
    
    // MARK: Project Needs
    let needs = Observable.just(SectionItem.needs(order: 1, placeholder: "Enter in your project needs!"))
      .map { item in
        return [
          SectionItem.title(order: 0, title: "Project Needs"),
          item
        ].sorted(by: { first, second -> Bool in first.order < second.order })
      }
      .map { Section(order: 5, items: $0) }
    
    // MARK: Conforming to the tableviewcell
    Observable.from([projectInfo, projectDesc, categories, screenshots, role, needs])
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .flatMap { $0 }
      .toArray()
      .map { $0.sorted(by: { $0.order < $1.order}) }
      .observeOn(MainScheduler.instance)
      .bind(to: items)
      .disposed(by: disposeBag)
  }
  
  private func setupCellClicks() {
    let onIconSetImageURL = iconSetImageURL.asObservable().share()
    
    onIconSetImageURL
      .filter { url in
        let data = try Data(contentsOf: url)
        let image = UIImage(data: data)!
        return !UIImage.isPictureNSFW(images: [image])
      }
      .subscribe(onNext: { [weak self] url in
        guard let this = self else { return }
        if let index = this.tableIndex.value {
          let item = this.items.value[index.section].items[index.row]
          switch item {
          case let .icon(order, title, _):
            let newItem = SectionItem.icon(order: order, title: title, imageURL: url)
            this.items.value[index.section].items[index.row] = newItem
          default: break
          }
        }
      })
      .disposed(by: disposeBag)
    
    onIconSetImageURL
      .filter { url in
        let data = try Data(contentsOf: url)
        let image = UIImage(data: data)!
        return UIImage.isPictureNSFW(images: [image])
      }
      .subscribe(onNext: { [weak self] _ in
        self?.onDeclinedImage.onNext(())
      })
      .disposed(by: disposeBag)
    
    
    let onScreenshotImages = onScreenshotSetImages.asObservable().share()
    
    onScreenshotImages
      .filter { assets in return !UIImage.isPictureNSFW(images: assets) }
      .asObservable()
      .subscribe(onNext: { [weak self] assets in
        guard let this = self else { return }
        if let index = this.tableIndex.value {
          let item = this.items.value[index.section].items[index.row]
          switch item {
          case let .screenshots(order, _):
            let newItem = SectionItem.screenshots(order: order, assets: assets)
            this.items.value[index.section].items[index.row] = newItem
          default: break
          }
        }
      })
      .disposed(by: disposeBag)
    
    onScreenshotImages
      .filter { assets in return UIImage.isPictureNSFW(images: assets) }
      .subscribe(onNext: { [weak self] _ in
        self?.onDeclinedImage.onNext(())
      })
      .disposed(by: disposeBag)
    
    onDecideIconImage
      .asObservable()
      .filter { [unowned self] _ in self.screenshotIndex.value == (self.screenshotImages.value?.count ?? 0)}
      .map { [weak self] in
        return !(self?.iconImage.value?.isEmpty ?? true)
      }
      .bind(to: onCreateIconImage)
      .disposed(by: disposeBag)
    
    let createIconImage = onCreateIconImage
      .asObservable()
      .do(onNext: { [weak self] _ in
        self?.screenshotIndex.value = 0
      })
      .share()
    
    // Check if true, if it is, then we can proceed
    createIconImage
      .filter { $0 }
      .map { [unowned self] _ in return self.iconImage.value }
      .filterNil()
      .flatMap { [unowned self] asset in return self.uploadAsset(file: asset, type: "image", projectIcon: true, projectId: self.projectId.value!) }
      .subscribe(
        onNext: { [weak self] _ in
          self?.onCreateProjectSuccess.onNext(())
        },
        onError: { [weak self] _ in
          self?.uploadingComplete.onNext(())
          // set up the error too
          let apiError = APIError(reason: "Something went wrong! Please check your internet connection!", error: true)
          self?.onError.onNext(apiError)
        }
      )
      .disposed(by: disposeBag)
    
    createIconImage
      .filter { !$0 }
      .subscribe(onNext: { [weak self] _ in
        self?.onCreateProjectSuccess.onNext(())
      })
      .disposed(by: disposeBag)
  }
  
  public func bindButtons() {
    itemSelected
      .subscribe(onNext: { [weak self] index in
        guard let this = self else { return }
        this.tableIndex.value = index
        switch this.items.value[index.section].items[index.row] {
        case .icon:
          this.iconClicked.onNext(())
        default:
          break
        }
      }).disposed(by: disposeBag)
    
    let selected = doneSelected
      .map { [unowned self] in
        return CreateProject(
          user_id: self.requestUserId(),
          name: self.name.value!.encode ?? "",
          category_id: self.category.value!.id,
          role_id: self.role.value!.id,
          project_description: self.description.value!.encode ?? "",
          description_needs: self.needs.value!.encode ?? ""
        )
      }
      .flatMap { [unowned self] createProject in return self.submitProject(forProject: createProject) }
      .share()
    
    // Get the button, after submission, and then attempt to upload the assets
    selected
      .map { $0.element }
      .filterNil()
      .filter { $0.statusCode == 200 }
      .do(onNext: { [weak self] _ in
        self?.showLoader.onNext(())
      })
      .map(Project.self)
      .map { $0.id }
      .bind(to: projectId)
      .disposed(by: disposeBag)

    projectId
      .asObservable()
      .filterNil()
      .map { [weak self] _ in return self?.screenshotImages.value }
      .filterNil()
      .flatMap { Observable.from($0) }
      .concatMap { [weak self] data in return self?.uploadAsset(file: data, type: "image", projectIcon: false, projectId: self!.projectId.value!) ?? Observable.empty() }
      .do(onNext: { [weak self] _ in
        self?.screenshotIndex.value += 1
      })
      .subscribe(
        onNext: { [weak self] _ in
          self?.onDecideIconImage.onNext(())
        },
        onError: { [weak self] _ in
          self?.uploadingComplete.onNext(())
          // set up the error too
          let apiError = APIError(reason: "Something went wrong! Please check your internet connection!", error: true)
          self?.onError.onNext(apiError)
        }
      )
      .disposed(by: disposeBag)
    
    selected
      .map { $0.element }
      .filterNil()
      .filter { $0.statusCode > 299 }
      .map(APIError.self)
      .do(onNext: { [weak self] _ in
        self?.uploadingComplete.onNext(())
      })
      .bind(to: onError)
      .disposed(by: disposeBag)
    
    selected
      .map { $0.error }
      .filterNil()
      .map { _ in
        return APIError(reason: "Something went wrong! Please check your internet connection.", error: true)
      }
      .do(onNext: { [weak self] _ in
        self?.uploadingComplete.onNext(())
      })
      .bind(to: onError)
      .disposed(by: disposeBag)
  }
  
  /// gets a list of roles for us
  private func requestRoles() -> Observable<[Role]> {
    return provider.rx.request(.roles)
      .asObservable()
      .filter(statusCode: 200)
      .map([Role].self)
      .catchErrorJustReturn([])
  }
  
  /// gets a list of categories for us
  private func requestCategories() -> Observable<[Category]> {
    return provider.rx.request(.categories)
      .asObservable()
      .filter(statusCode: 200)
      .map([Category].self)
      .catchErrorJustReturn([])
  }
  
  /// Gets userid from the token
  private func requestUserId() -> Int {
    // get token
    let token = UserDefaults.standard.string(forKey: "token")!
    let userId = try! decode(jwt: token).body["user_id"] as! Int
    return userId
  }
  
  /// Attempt to submit the credentials to create a new project
  private func submitProject(forProject project: CreateProject) -> Observable<Event<Response>> {
    return provider.rx.request(.createProject(project.user_id, project))
      .asObservable()
      .materialize()
  }
  
  /// Attemp to upload asset
  private func uploadAsset(file: Data, type: String, projectIcon: Bool, projectId: Int) -> Observable<Response> {
    return provider.rx.request(.createAsset(file, type, projectIcon, projectId))
      .asObservable()
  }
}

// MARK: SectionItem
extension CreateProjectViewModel {
  
  public struct Section {
    public let order: Int
    public var items: [SectionItem]
  }
  
  public enum SectionItem {
    case icon(order: Int, title: String, imageURL: URL)
    case name(order: Int, title: String, placeholder: String)
    case description(order: Int, placeholder: String)
    case category(order: Int, title: String, categories: [Category])
    case screenshots(order: Int, assets: [UIImage])
    case role(order: Int, title: String, roles: [Role])
    case needs(order: Int, placeholder: String)
    case title(order: Int, title: String)
    case screenshotTitle(order: Int, title: String)
  }
}

// MARK: SectionModelType
extension CreateProjectViewModel.Section: SectionModelType {
  public typealias Item = CreateProjectViewModel.SectionItem
  
  public init(original: CreateProjectViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}


extension CreateProjectViewModel.SectionItem {
  public var order: Int {
    switch self {
    case let .category(order, _, _):
      return order
    case let .description(order, _):
      return order
    case let .icon(order, _, _):
      return order
    case let .name(order, _, _):
      return order
    case let .needs(order, _):
      return order
    case let .role(order, _, _):
      return order
    case let .screenshots(order, _):
      return order
    case let .title(order, _):
      return order
    case let .screenshotTitle(order, _):
      return order
    }
  }
}

// MARK: Equatable
extension CreateProjectViewModel.Section: Equatable {
  public static func ==(lhs: CreateProjectViewModel.Section, rhs: CreateProjectViewModel.Section) -> Bool {
    return lhs.order == rhs.order
  }
}

// MARK: Equatable
extension CreateProjectViewModel.SectionItem: Equatable {
  public static func ==(lhs: CreateProjectViewModel.SectionItem, rhs: CreateProjectViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}
