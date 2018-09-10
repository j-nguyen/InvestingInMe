//
//  DocumentViewModel.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-04-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

public protocol DocumentViewModelProtocol {
  var urlRequest: URLRequest { get }
  var initial: Bool { get }
  var title: String { get }
}

public class DocumentViewModel: DocumentViewModelProtocol {
  // MARK: Provider
  private let url: URL
  
  // MARK: Properties
  public var urlRequest: URLRequest
  public var initial: Bool
  public var title: String
  
  public init(title: String, url: URL, initial: Bool) {
    self.title = title
    self.url = url
    self.initial = initial
    
    urlRequest = URLRequest(url: self.url)
  }
}
