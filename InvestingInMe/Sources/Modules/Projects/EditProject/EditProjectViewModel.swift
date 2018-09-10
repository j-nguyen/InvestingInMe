//
//  EditProjectViewModel.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-03-30.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxDataSources
import JWTDecode
import Nuke
import RxNuke

public protocol EditProjectViewModelProtocol {
  var items: Variable<[EditProjectViewModel.Section]> { get }
  var itemSelected: Observable<IndexPath>! { get set }
  var doneSelected: Observable<Void>! { get set }
  var iconClicked: PublishSubject<Void> { get }
  var iconSetImageURL: PublishSubject<URL> { get }
  var tableIndex: Variable<IndexPath?> { get }
  // events
  var onError: PublishSubject<String> { get }
  var onScreenshotSetImages: PublishSubject<[UIImage]> { get }
  var updateComplete: PublishSubject<Void> { get }
  var onDeclinedImage: PublishSubject<Void> { get }
  var showLoader: PublishSubject<Void> { get }
  var loadingComplete: PublishSubject<Void> { get }
  var assetsUploadSuccess: PublishSubject<Void> { get }
  var iconUploadSuccess: PublishSubject<Void> { get }
  var endUpload: PublishSubject<Void> { get }
  // data items
  var iconImage: PublishSubject<Data> { get }
  var screenshotImages: Variable<[Data]> { get }
  var name: Variable<String?> { get }
  var description: Variable<String?> { get }
  var category: Variable<Category?> { get }
  var role: Variable<Role?> { get }
  var needs: Variable<String?> { get }
  var currentProjectId: Variable<Int?> { get }
  var projectId: Int! { get }
  var isButtonEnabled: Observable<Bool> { get }
  // events
  func bindButtons()
}

public class EditProjectViewModel: EditProjectViewModelProtocol {
  
  // MARK: Provider
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  public var items: Variable<[EditProjectViewModel.Section]> = Variable([])
  public var itemSelected: Observable<IndexPath>!
  public var doneSelected: Observable<Void>!
  
  public var iconClicked: PublishSubject<Void> = PublishSubject()
  public var iconSetImageURL: PublishSubject<URL> = PublishSubject()
  public var onError: PublishSubject<String> = PublishSubject()
  public var onScreenshotSetImages: PublishSubject<[UIImage]> = PublishSubject()
  private var deleteAssetSuccess: PublishSubject<Void> = PublishSubject()
  private var uploadIcon: PublishSubject<Void> = PublishSubject()
  public var tableIndex: Variable<IndexPath?> = Variable(nil)
  public var updateComplete: PublishSubject<Void> = PublishSubject()
  public var onDeclinedImage: PublishSubject<Void> = PublishSubject()
  public var showLoader: PublishSubject<Void> = PublishSubject()
  public var loadingComplete: PublishSubject<Void> = PublishSubject()
  public var endUpload: PublishSubject<Void> = PublishSubject()
  // form data for creating project
  public var iconImage: PublishSubject<Data> = PublishSubject()
  public var screenshotImages: Variable<[Data]> = Variable([])
  public var name: Variable<String?> = Variable(nil)
  public var description: Variable<String?> = Variable(nil)
  public var category: Variable<Category?> = Variable(nil)
  public var role: Variable<Role?> = Variable(nil)
  public var needs: Variable<String?> = Variable(nil)
  public var projectId: Int!
  public var currentProjectId: Variable<Int?> = Variable(-1)
  private var projectIcon: Variable<Asset?> = Variable(nil)
  private var assets: Variable<[Asset]> = Variable([])
  public var assetsUploadSuccess: PublishSubject<Void> = PublishSubject()
  public var iconUploadSuccess: PublishSubject<Void> = PublishSubject()
  private var assetIndex: Variable<Int> = Variable(0)
  
  // MARK: Observables
  public var isButtonEnabled: Observable<Bool> {
    return Observable.combineLatest(
      name.asObservable(), description.asObservable(),
      category.asObservable(), role.asObservable(), needs.asObservable())
    { name, desc, category, role, needs in
      return name?.isNotEmpty ?? false && category != nil && role != nil && needs?.isNotEmpty ?? false && desc?.isNotEmpty ?? false
    }
  }
  
  private let disposeBag = DisposeBag()
  
  public init(provider: MoyaProvider<InvestingInMeAPI>, projectId: Int) {
    self.provider = provider
    self.projectId = projectId
    
    setup()
    setupCellClicks()
  }
  
  private func setup() {
    
    //Fetch the current Project
    let project = requestProjectDetails(projectId: self.projectId)
      .do(onNext: { [weak self] _ in
        self?.loadingComplete.onNext(())
      })
      .materialize()
      .map { $0.element }
      .filterNil()
      .share()
    
    //Get all assets from the current project exlcuding project icon
     project
      .map { $0.assets }
      .map { assets in return assets.filter { !$0.project_icon } }
      .bind(to: assets)
      .disposed(by: disposeBag)
    
    //Get the project icon from the current project
    project
      .map { $0.assets }
      .map { assets in return assets.filter { $0.project_icon }.first }
      .filterNil()
      .bind(to: projectIcon)
      .disposed(by: disposeBag)
    
    //Map the current project to the SectionItems for the EditProject cells
    Observable.zip(project, self.requestCategories(), self.requestRoles())
      .map { [unowned self] project -> [SectionItem] in
        let imageUrl = project.0.assets.first(where: { (asset) -> Bool in
          return asset.project_icon
        })!.url
        self.category.value = project.0.category
        self.role.value = project.0.role
        self.name.value = project.0.name.decode
        self.description.value = project.0.project_description.decode
        self.needs.value = project.0.description_needs.decode
        return [
          SectionItem.icon(order: 0, title: "Icon", imageURL: imageUrl),
          SectionItem.name(order: 1, title: "Project Name", placeholder: "Enter your project name"),
          SectionItem.title(order: 2, title: "Project Description"),
          SectionItem.description(order: 3, placeholder: "Enter in your project description!"),
          SectionItem.category(order: 4, title: "Category", categories: project.1, currentCategory: project.0.category.id),
          SectionItem.screenshotTitle(order: 5, title: "Screenshots"),
          SectionItem.screenshots(order: 6, assets: project.0.assets.filter { !$0.project_icon }.map { $0.url }),
          SectionItem.role(order: 7, title: "Roles", roles: project.2, currentRole: project.0.role.id),
          SectionItem.title(order: 8, title: "Project Needs"),
          SectionItem.needs(order: 9, placeholder: "Enter in your project needs!")
        ]
      }
      .map { Section(order: 0, items: $0) }
      .toArray()
      .bind(to: items)
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
    
    doneSelected
      .map { [unowned self] in
        return UpdateProject(
          name: self.name.value!.encode ?? "",
          category_id: self.category.value!.id,
          role_id: self.role.value!.id,
          project_description: self.description.value!.encode ?? "",
          description_needs: self.needs.value!.encode ?? ""
        )
      }
      .flatMap { [unowned self] updateProject in return self.updateProject(projectId: self.projectId, parameters: updateProject) }
      .filter(statusCode: 200)
      .subscribe(onNext: { _ in
        self.updateComplete.onNext(())
      }).disposed(by: disposeBag)
    
  }
  
  private func setupCellClicks() {
    let onIconSetImageURL = iconSetImageURL.asObservable().share()
    
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
    
    //Change the cell to the new image and call the deleteIcon subject
    onIconSetImageURL
      .filter { url in
        let data = try Data(contentsOf: url)
        let image = UIImage(data: data)!
        return !UIImage.isPictureNSFW(images: [image])
      }
      .do(onNext: { [weak self] _ in
        self?.showLoader.onNext(())
      })
      .subscribe(onNext: { [weak self] url in
        guard let this = self else { return }
        if let index = this.tableIndex.value {
          let item = this.items.value[index.section].items[index.row]
          switch item {
          case let .icon(order, title, _):
            let newItem = SectionItem.icon(order: order, title: title, imageURL: url)
            this.items.value[index.section].items[index.row] = newItem
            this.uploadIcon.onNext(())
          default: break
          }
        }
      }).disposed(by: disposeBag)

    //Setup the call to delete the current Icon and upload the new one
    Observable.zip(uploadIcon.asObservable(), iconImage.asObservable())
      .map { $0.1 }
      .flatMap { [unowned self] icon -> Observable<Asset> in
        return self.uploadAsset(file: icon, type: "image", projectIcon: true, projectId: self.projectId)
      }
      .map{ $0.url }
      .subscribe(
        onNext: { [weak self] asset in
          self?.iconUploadSuccess.onNext(())
        },
        onError: { [weak self] _ in
          self?.iconUploadSuccess.onNext(())
          self?.onError.onNext("Something went wrong. Please check your internet connection!")
        }
      ).disposed(by: disposeBag)
    
    //Take the uploaded images and run them through the NSFW image filtering and Base 64 Encode them
    onScreenshotSetImages
      .asObservable()
      .filter { assets in return !UIImage.isPictureNSFW(images: assets) }
      .do(onNext: { [weak self] _ in
        self?.showLoader.onNext(())
      })
      .map { images -> [Data] in
        return images.map { image -> Data in
          return UIImagePNGRepresentation(image)!
        }
      }
      .do(onNext: { [weak self] assets in
        self?.screenshotImages.value = assets
      })
      .flatMap { [unowned self] _ in return Observable.from(self.assets.value) }
      .flatMap { [unowned self] data in return self.deleteAsset(assetId: data.id) }
      .do(onNext: { [weak self] _ in
        self?.assetIndex.value += 1
      })
      .subscribe(
        onNext: { [weak self] _ in
          guard let this = self else { return }
          if this.assetIndex.value == this.assets.value.count {
            self?.deleteAssetSuccess.onNext(())
          }
        },
        onError: { [weak self] _ in
          self?.deleteAssetSuccess.onNext(())
          self?.onError.onNext("Something went wrong. Please check your internet connection!")
        }
      ).disposed(by: disposeBag)
    
    //If the uploaded image(s) aren't safe for work, trigger the declinedImage PublishSubject
    onScreenshotSetImages
      .filter { assets in return UIImage.isPictureNSFW(images: assets) }
      .subscribe(onNext: { [weak self] _ in
        self?.onDeclinedImage.onNext(())
      })
      .disposed(by: disposeBag)
    
    //If projects were successfully deleted, upload new assets, and refresh the screenshots cell
    deleteAssetSuccess
      .asObservable()
      .do(onNext: { [weak self] _ in self?.assets.value.removeAll() })
      .map { [unowned self] _ -> [Data] in return self.screenshotImages.value }
      .flatMap { asset -> Observable<Data> in return Observable.from(asset) }
      .flatMap { [unowned self] image -> Observable<Asset> in
        return self.uploadAsset(file: image, type: "image", projectIcon: false, projectId: self.projectId)
      }
      .scan([]) { [weak self] initial, asset -> [URL] in
        var newArray = initial
        self?.assets.value.append(asset)
        newArray.append(asset.url)
        return newArray
      }
      .subscribe(
        onNext: { [weak self] assets in
          guard let this = self else { return }
            let item = this.items.value[0].items[6]
            switch item {
            case let .screenshots(order, _):
              let newItem = SectionItem.screenshots(order: order, assets: assets)
              this.items.value[0].items[6] = newItem
            default: break
          }
          this.assetIndex.value = 0
          this.assetsUploadSuccess.onNext(())
        },
        onError: { [weak self] _ in
          self?.assetIndex.value = 0
          self?.assetsUploadSuccess.onNext(())
          self?.onError.onNext("Something went wrong! Please check your internet connection!")
        }
      ).disposed(by: disposeBag)
  }
  
  //Update the current project
  private func updateProject(projectId: Int, parameters: UpdateProject) -> Observable<Response> {
    return provider.rx.request(.updateProject(projectId, parameters))
      .asObservable()
  }
  
  //Get the current project the user wants to edit
  private func requestProjectDetails(projectId: Int) -> Observable<Project> {
    return provider.rx.request(.projectsDetail(projectId))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(Project.self)
  }
  
  //Get a list of all roles
  private func requestRoles() -> Observable<[Role]> {
    return provider.rx.request(.roles)
      .asObservable()
      .filter(statusCode: 200)
      .map([Role].self)
      .catchErrorJustReturn([])
  }
  
  //Get a list of all categories
  private func requestCategories() -> Observable<[Category]> {
    return provider.rx.request(.categories)
      .asObservable()
      .filter(statusCode: 200)
      .map([Category].self)
      .catchErrorJustReturn([])
  }
  
  //Attempt to upload asset
  private func uploadAsset(file: Data, type: String, projectIcon: Bool, projectId: Int) -> Observable<Asset> {
    return provider.rx.request(.createAsset(file, type, projectIcon, projectId))
      .asObservable()
      .map(Asset.self)
  }
  
  //Attempt to delete an asset
  private func deleteAsset(assetId: Int) -> Observable<Response> {
    return provider.rx.request(.deleteAssets(assetId))
      .asObservable()
  }
  
}

// MARK: SectionItem
extension EditProjectViewModel {
  
  public struct Section {
    public let order: Int
    public var items: [SectionItem]
  }
  
  public enum SectionItem {
    case icon(order: Int, title: String, imageURL: URL)
    case name(order: Int, title: String, placeholder: String)
    case description(order: Int, placeholder: String)
    case category(order: Int, title: String, categories: [Category], currentCategory: Int)
    case screenshots(order: Int, assets: [URL])
    case role(order: Int, title: String, roles: [Role], currentRole: Int)
    case needs(order: Int, placeholder: String)
    case title(order: Int, title: String)
    case screenshotTitle(order: Int, title: String)
  }
}

// MARK: SectionModelType
extension EditProjectViewModel.Section: SectionModelType {
  public typealias Item = EditProjectViewModel.SectionItem
  
  public init(original: EditProjectViewModel.Section, items: [Item]) {
    self = original
    self.items = items
  }
}


extension EditProjectViewModel.SectionItem {
  public var order: Int {
    switch self {
    case let .category(order, _, _, _):
      return order
    case let .description(order, _):
      return order
    case let .icon(order, _, _):
      return order
    case let .name(order, _, _):
      return order
    case let .needs(order, _):
      return order
    case let .role(order, _, _, _):
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
extension EditProjectViewModel.Section: Equatable {
  public static func ==(lhs: EditProjectViewModel.Section, rhs: EditProjectViewModel.Section) -> Bool {
    return lhs.order == rhs.order
  }
}

// MARK: Equatable
extension EditProjectViewModel.SectionItem: Equatable {
  public static func ==(lhs: EditProjectViewModel.SectionItem, rhs: EditProjectViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}

