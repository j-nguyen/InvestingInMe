//
//  Token.swift
//  InvestingInMe
//
//  Created by Liam Goodwin on 2018-02-09.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation
import RxSwift
import JWTDecode
import UIKit
import MaterialComponents

public struct Token: Decodable {
  public let token: String
}
