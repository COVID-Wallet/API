//
//  DateFormatterCache.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 11/08/2021.
//

import Foundation

class DateFormatterCache {
    
    static let shared = DateFormatterCache()
    
    private func makeDateFormatter(dateFormat: String) -> DateFormatter {
        let df = DateFormatter()
        
        df.dateFormat = dateFormat
        
        return df
    }
    
    lazy var dateOnlyFormatter: DateFormatter = makeDateFormatter(dateFormat: "yyyy-MM-dd")
    lazy var iso8601DateFormatter: DateFormatter = makeDateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ssxxxxx")
    
    private init() {}
}
