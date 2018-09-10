//
//  NetworkCalls.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-08.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import Moya
import Alamofire

//API Endpoints
public enum InvestingInMeAPI {
  case login(String)
  case user(Int)
  case requestUpdateUser(Int, String, Int?, String, String, String)
  case featuredProjects
  case userProjects(Int)
  case projectsDetail(Int)
  case allProjects([String]?, [String]?, String?)
  case roles
  case categories
  case allConnections(Int)
  case deleteConnection(Int)
  case updateConnection(Int, Bool)
  case createProject(Int, CreateProject)
  case createAsset(Data, String, Bool, Int)
  case createConnection(Int, Int, Bool, String)
  case currentConnection(Int, Int)
  case deleteProject(Int)
  case deleteAssets(Int)
  case updateProject(Int, UpdateProject)
  case feature(Int, Int)
  case notifications
  case updateUserNotification(Int, String)
}

extension InvestingInMeAPI: TargetType {
  
  public var baseURL: URL { return URL(string: Constants.API_URL)! }
  
  public var path: String {
    switch self {
      case .login:
        return "/users/login"
      case let .user(userId), let .requestUpdateUser(userId, _, _, _, _, _), let .updateUserNotification(userId, _):
        return "/users/\(userId)"
      case .featuredProjects:
        return "/featured"
      case let .userProjects(userId):
        return "/users/\(userId)/projects"
      case let .projectsDetail(projectId):
        return "/projects/\(projectId)"
      case .roles:
        return "/users/roles"
      case let .allConnections(userId):
        return "/users/\(userId)/connections"
      case .allProjects:
        return "/projects"
      case .categories:
        return "/projects/categories"
      case .deleteConnection(let connectionId):
        return "/connections/\(connectionId)"
      case let .updateConnection(userId, _):
        return "/connections/\(userId)"
      case .createProject(let userId, _):
        return "/users/\(userId)/projects"
      case .createAsset:
        return "/assets"
      case .createConnection(_, _, _, _):
        return "/connections/"
      case let .currentConnection(userId, _):
        return "/users/\(userId)/connections"
      case let .deleteProject(projectId):
        return "/projects/\(projectId)"
      case let .deleteAssets(assetId):
        return "/assets/\(assetId)"
      case let .updateProject(projectId, _):
        return "/projects/\(projectId)"
      case .feature(_, _):
        return "/featured"
      case .notifications:
        return "/notifications"
    }
  }
  
  public var method: Moya.Method {
    switch self {
    case .login, .createProject, .createAsset, .createConnection, .feature:
      return .post
    case .featuredProjects, .user, .userProjects, .roles, .projectsDetail, .allConnections, .allProjects, .categories, .currentConnection:
      return .get
    case .requestUpdateUser, .updateConnection, .updateProject, .updateUserNotification:
      return .patch
    case .deleteConnection, .deleteProject, .deleteAssets:
      return .delete
    default:
      return .get
    }
  }
  
  public var task: Task {
    switch self {
    case let .login(token):
      return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
    case .featuredProjects, .user, .userProjects, .roles, .projectsDetail, .allConnections, .deleteConnection, .categories, .deleteProject, .deleteAssets:
      return .requestPlain
    case let .requestUpdateUser(_, location, role_id, phone_number, description, experience_and_credentials):
      return .requestParameters(
        parameters: [
          "location": location,
          "role_id": role_id,
          "phone_number": phone_number,
          "description": description,
          "experience_and_credentials": experience_and_credentials,
        ],
        encoding: JSONEncoding.default
      )
    case let .updateConnection(connectionId, accepted):
      return .requestParameters(
        parameters: [
          "id": connectionId,
          "accepted": accepted
        ],
      encoding: JSONEncoding.default
      )
    case let .updateProject(_, updateProject):
      return .requestJSONEncodable(updateProject)
    case let .createProject(_, createProject):
      return .requestJSONEncodable(createProject)
    case let .createAsset(asset, type, projectIcon, projectId):
      let projectIconString = (projectIcon) ? "true" : "false"
      let projectIdString = "\(projectId)".data(using: .utf8)!
      let image = MultipartFormData(provider: .data(asset), name: "file", fileName: "test", mimeType: asset.mimeType)
      let projectIconData = MultipartFormData(provider: .data(projectIconString.data(using: .utf8)!), name: "projectIcon")
      let projectIdData = MultipartFormData(provider: .data(projectIdString), name: "projectId")
      return .uploadCompositeMultipart([image, projectIconData, projectIdData], urlParameters: ["type": type])
    case let .createConnection(inviterId, inviteeId, accepted, message):
      return .requestParameters(
        parameters: [
          "user_id": inviterId,
          "invitee_id": inviteeId,
          "accepted": accepted,
          "message": message
        ], encoding: JSONEncoding.default
      )
      case let .allProjects(category, role, search):
        var params: [String: Any] = [:]
        if let category = category, category.isNotEmpty {
          params["category"] = category
        }
  
        if let role = role, role.isNotEmpty {
          params["role"] = role
        }
  
        if let search = search {
          params["search"] = search
        }
       return .requestParameters(parameters: params, encoding: URLEncoding.default)
    case let .currentConnection(_, invitee_id):
      return .requestParameters(
          parameters: [
            "connection_id": invitee_id
          ], encoding: URLEncoding.default
      )
    case let .feature(project_id, duration):
      return .requestParameters(parameters: [
        "project_id": project_id,
        "duration": duration
      ],
        encoding: JSONEncoding.default
      )
    case let .updateUserNotification(_, playerId):
      return .requestParameters(parameters: [
        "player_id": playerId
      ],
        encoding: JSONEncoding.default
      )
    default:
      return .requestPlain
    }
  }
  
  public var sampleData: Data {
    return "Testing".data(using: .utf8)!
  }
  
  public var headers: [String: String]? {
    return ["Content-Type": "application/json"]
  }
}
