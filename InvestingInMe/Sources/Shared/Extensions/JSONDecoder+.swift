//
//  JSONDecoder+.swift
//  InvestingInMe
//
//  Created by Johnny Nguyen on 2018-02-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation

extension JSONDecoder {
	public static var Decode: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .custom( { decoder -> Date in
			let container = try decoder.singleValueContainer()
			let dateStr = try container.decode(String.self)
			
			let currDate: Date = Date()
			let formatter = DateFormatter()
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
			if let date = formatter.date(from: dateStr) {
				return date
			}
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			if let date = formatter.date(from: dateStr) {
				return date
			}
			return currDate
		})
		return decoder
	}
}
