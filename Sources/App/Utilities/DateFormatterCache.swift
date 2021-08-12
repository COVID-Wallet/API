//
//  DateFormatterCache.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 11/08/2021.
//

import Foundation

class DateFormatterCache {
    
    static let shared = DateFormatterCache()
    
    lazy var humanReadableFormatter: DateFormatter = {
        let df = DateFormatter()
        
        df.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        return df
    }()
    
    lazy var passFormatter: DateFormatter = {
        let df = DateFormatter()
        
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'-00:00'"
        
        return df
    }()
    
    private init() {}
}
