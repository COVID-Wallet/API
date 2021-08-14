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
    lazy var dateOnlyHumanReadableFormatter: DateFormatter = makeDateFormatter(dateFormat: "dd-MM-yyyy")
    lazy var humanReadableFormatter: DateFormatter = makeDateFormatter(dateFormat: "dd-MM-yyyy HH:mm:ss")
    lazy var passFormatter: DateFormatter = makeDateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss'-00:00'")
    
    private init() {}
}
