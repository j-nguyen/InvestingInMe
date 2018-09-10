//
//  EditProfileViewModel.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-12.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional
import RxDataSources
import Moya
import JWTDecode

public protocol EditProfileViewModelProtocol {
  //Declare the Section for the Edit ViewModel
  var section: Variable<[EditProfileViewModel.Section]> { get }
  
  //Declare the editable fields for the Profile
  var location: Variable<String> { get }
  var role: Variable<Int?> { get }
  var phone_number: Variable<String> { get }
  var description: Variable<String> { get }
  var experience_and_credentials: Variable<String> { get }
  
  //Declare the various submit button verifications
  var submitButtonTap: Observable<Void>! { get set }
  var submitButtonSuccess: PublishSubject<Bool> { get }
  var submitButtonFail: PublishSubject<APIError> { get }
  var reloadProfile: PublishSubject<Void> { get }
  
  //Declare the bind Save button method
  func bindButtons()
}

public class EditProfileViewModel: EditProfileViewModelProtocol {
  
  //MARK: Variable Declarations
  //Declare the users id, Moya provider, and Profile View model
  private let userId: Int
  private let profileViewModel: ProfileViewModelProtocol
  private let provider: MoyaProvider<InvestingInMeAPI>
  
  //Instantiate the editable fields from the Edit Profile Protocol
  public var location: Variable<String> = Variable("")
  public var role: Variable<Int?> = Variable(nil)
  public var phone_number: Variable<String> = Variable("")
  public var description: Variable<String> = Variable("")
  public var experience_and_credentials: Variable<String> = Variable("")

  //Instantiate the section for the Edit Profile to hold the different sections of the page
  public var section: Variable<[EditProfileViewModel.Section]> = Variable([])
  
  //Instantiate the submit button elements, and reloading of profile
  public var submitButtonTap: Observable<Void>!
  public var submitButtonSuccess: PublishSubject<Bool> = PublishSubject()
  public var submitButtonFail: PublishSubject<APIError> = PublishSubject()
  public var reloadProfile: PublishSubject<Void> = PublishSubject()

  //MARK: Dispose
  private let disposeBag: DisposeBag = DisposeBag()
  
  //Declare public initializer and reload the Profile
  public init(userId: Int, profileViewModel: ProfileViewModelProtocol, provider: MoyaProvider<InvestingInMeAPI>) {
    self.userId = userId
    self.profileViewModel = profileViewModel
    self.provider = provider
    
    reloadProfile
      .subscribe(onNext: { 
        profileViewModel.refreshContent.onNext(())
      }).disposed(by: disposeBag)
    
    //Setup the information mapping for the Profile
    setup(userId)
  }
  
  //MARK: Setup
  private func setup(_ user_id: Int) {
    
    //Request the current user
    let requestedUser = user(user_id: user_id)
      .materialize()
      .share()
    
    //Map valid elements from the user to edit
    let elements = requestedUser
      .map { $0.element }
      .filterNil()
      .share()
    
    elements
      .map { $0.role?.id }
      .filterNil()
      .bind(to: self.role)
      .disposed(by: disposeBag)
    
    //Create elements of the profile information we want to edit
    Observable.zip(elements, allRoles().asObservable())
      .map { (arg: (User, [Role])) -> [SectionItem] in
        let (user, allRoles) = arg
        return [
          SectionItem.location(order: 0, location: "Location", value: user.location, placeholder: "Enter in your location"),
          SectionItem.role(order: 1, role: user.role, roles: allRoles),
          SectionItem.phone_number(order: 2, phone_number: "Phone Number", value: user.phone_number, placeholder: "Enter in your phone number"),
          SectionItem.title(order: 3, value: "Description"),
          SectionItem.description(order: 4, description: user.description, placeholder: "Enter in your description"),
          SectionItem.title(order: 5, value: "Experience and Credentials"),
          SectionItem.experience_and_credentials(order: 6, experience_and_credentials: user.experience_and_credentials, placeholder: "Enter in your experience and credentials")
        ].sorted(by: { $0.order < $1.order })
      }
      .map { Section.profile(order: 0, items: $0) }
      .toArray()
      .bind(to: section)
      .disposed(by: disposeBag)
  }
  
  //MARK: Submit Verification
  public func bindButtons() {
    
    //When submit button is tapped it will take all edited profile fields and attempt to save them using requestUpdateUser
    let btn = submitButtonTap
      .flatMap { [weak self] _ -> Observable<Response> in
        guard let this = self else { fatalError() }
        return this.requestUpdateUser(
          user_id: this.userId,
          location: this.location.value,
          role_id: this.role.value,
          phone_number: this.phone_number.value,
          description: this.description.value,
          experience_and_credentials: this.experience_and_credentials.value
        )
      }
      .share()
    
    //Check if API update failed
    btn
      .filter { $0.statusCode >= 299 }
      .map(APIError.self)
      .bind(to: submitButtonFail)
      .disposed(by: disposeBag)
    
    //Check if API update was successful
    btn
      .filter { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .map { $0.statusCode >= 200 && $0.statusCode <= 299 }
      .bind(to: submitButtonSuccess)
      .disposed(by: disposeBag)
  }
  
  //Setup requestUpdateUser method to call call our update function and return an Observable Response
  private func requestUpdateUser(user_id: Int, location: String, role_id: Int?, phone_number: String, description: String, experience_and_credentials: String) -> Observable<Response> {
    return provider.rx.request(.requestUpdateUser(user_id, location, role_id, phone_number, description, experience_and_credentials))
      .asObservable()
  }
  
  //Get the requested user from the API
  private func user(user_id: Int) -> Observable<User> {
    return provider.rx.request(.user(user_id))
      .asObservable()
      .map(User.self)
  }
  
  //Get all of the roles available from the API
  private func allRoles() -> Observable<[Role]> {
    return provider.rx.request(.roles)
      .asObservable()
      .map([Role].self)
  }
}

//MARK: EditProfileViewModel Extension
//Declare the Edit Profile extension
extension EditProfileViewModel {
  
  //Declare the different sections of the EditProfile page
  public enum Section {
    case profile(order: Int, items: [SectionItem])
  }
  
  //Declare the different profile section items
  public enum SectionItem {
    case description(order: Int, description: String, placeholder: String)
    case title(order: Int, value: String)
    case role(order: Int, role: Role?, roles: [Role])
    case location(order: Int, location: String, value: String, placeholder: String)
    case phone_number(order: Int, phone_number: String, value: String, placeholder: String)
    case experience_and_credentials(order: Int, experience_and_credentials: String, placeholder: String)
  }
}

//MARK: SectionModelType - RxDataSources
extension EditProfileViewModel.Section: SectionModelType {
  
  //Declare the items for the EditProfile section item
  public typealias Items = EditProfileViewModel.SectionItem
  
  //Setup the mapping for the different items
  public var items: [Items] {
    switch self {
      case let .profile(_, items):
        return items.map { $0 }
    }
  }
  
  //Setup the ordering for the different sections
  public var order: Int {
    switch self {
      case let .profile(order, _):
        return order
    }
  }
  
  //Setup the comparison between original and different SectionItems
  public init(original: EditProfileViewModel.Section, items: [EditProfileViewModel.SectionItem]) {
    switch original {
      case let .profile(order, _):
        self = .profile(order: order, items: items)
    }
  }
}

//MARK: EditProfile Equatable
extension EditProfileViewModel.SectionItem: Equatable {
  
  //Setup the ordering for each SectionItem
  public var order: Int {
    switch self {
      case .description(let order, _, _):
        return order
      case .role(let order, _, _):
        return order
      case .location(let order, _, _, _):
        return order
      case .phone_number(let order, _, _, _):
        return order
      case .experience_and_credentials(let order, _, _):
        return order
      case .title(let order, _):
        return order
    }
  }
  
  //Auto-implemented method to ensure SectionItems conform to the Equatable protocol
  public static func ==(lhs: EditProfileViewModel.SectionItem, rhs: EditProfileViewModel.SectionItem) -> Bool {
    return lhs.order == rhs.order
  }
}
