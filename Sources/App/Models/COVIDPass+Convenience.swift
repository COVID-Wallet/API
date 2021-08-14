//
//  COVIDPass+Convenience.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 11/08/2021.
//

import Foundation

extension COVIDPass {
    
    var expiryDate: Date {
        Date(timeIntervalSince1970: TimeInterval(validUntil))
    }
    
    var expiryDatePassFormat: String {
        DateFormatterCache.shared.passFormatter.string(from: expiryDate)
    }
    
    var expiryDateHumanFormat: String {
        DateFormatterCache.shared.humanReadableFormatter.string(from: expiryDate)
    }
}
