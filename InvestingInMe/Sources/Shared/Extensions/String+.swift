//
//  String+.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-04-06.
//  Copyright © 2018 InvestingInMe. All rights reserved.
//

import Foundation

extension String {
  /// Decodes string back to ASCII so that we can send to our database
  public var decode: String? {
    let data = self.data(using: .utf8)!
    let decodedString = String(data: data, encoding: .nonLossyASCII)
    return decodedString
  }
  
  /// Encodes back to UTF-8 Format
  public var encode: String? {
    let data = self.data(using: .nonLossyASCII, allowLossyConversion: true)!
    let encodedString = String(data: data, encoding: .utf8)
    return encodedString
  }
}
