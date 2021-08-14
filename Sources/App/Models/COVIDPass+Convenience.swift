//
//  COVIDPass+Convenience.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 11/08/2021.
//

import Foundation

extension COVIDPass {
    
    var expiryDate: Date {
        switch data.certificateData {
        case .recovery(let r):
            return DateFormatterCache.shared.dateOnlyFormatter.date(from: r.validUntil) ??
                Date(timeIntervalSince1970: TimeInterval(validUntil))
            
        case .test, .vaccination:
            return Date(timeIntervalSince1970: TimeInterval(validUntil))
        }
    }
    
    var validFromDate: Date {
        switch data.certificateData {
        case .recovery(let r):
            return DateFormatterCache.shared.dateOnlyFormatter.date(from: r.validFrom) ??
                Date(timeIntervalSince1970: TimeInterval(validFrom))
            
        case .test, .vaccination:
            return Date(timeIntervalSince1970: TimeInterval(validFrom))
        }
    }
    
    var expiryDatePassFormat: String {
        DateFormatterCache.shared.passFormatter.string(from: expiryDate)
    }
    
    var expiryDateHumanFormat: String {
        DateFormatterCache.shared.humanReadableFormatter.string(from: expiryDate)
    }
    
    var validFromHumanFormat: String {
        DateFormatterCache.shared.humanReadableFormatter.string(from: validFromDate)
    }
    
    var testSampleCollectionDateHumanFormat: String? {
        guard case let COVIDPass.Data.CertificateData.test(t) = data.certificateData,
              let date = DateFormatterCache.shared.dateOnlyFormatter.date(from: t.testSampleCollectionDate) else {
            return nil
        }
        
        return DateFormatterCache.shared.dateOnlyHumanReadableFormatter.string(from: date)
    }
}
