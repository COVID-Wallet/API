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
    
    var dateOfBirth: Date? {
        return DateFormatterCache.shared.dateOnlyFormatter.date(from: data.dateOfBirth)
    }
    
    var dateOfBirthPassFormat: String? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        
        return DateFormatterCache.shared.iso8601DateFormatter.string(from: dateOfBirth)
    }
    
    var dateOfVaccinationPassFormat: String? {
        guard case let COVIDPass.Data.CertificateData.vaccination(v) = data.certificateData,
              let date = DateFormatterCache.shared.dateOnlyFormatter.date(from: v.dateOfVaccination) else {
            return nil
        }
        
        return DateFormatterCache.shared.iso8601DateFormatter.string(from: date)
    }
    
    var expiryDatePassFormat: String {
        DateFormatterCache.shared.iso8601DateFormatter.string(from: expiryDate)
    }
    
    var validFromPassFormat: String {
        DateFormatterCache.shared.iso8601DateFormatter.string(from: validFromDate)
    }
    
    var recoveryFirstPositiveDatePassFormat: String? {
        guard case let COVIDPass.Data.CertificateData.recovery(r) = data.certificateData,
              let date = DateFormatterCache.shared.dateOnlyFormatter.date(from: r.firstPositiveTestDate) else {
            return nil
        }
        
        return DateFormatterCache.shared.iso8601DateFormatter.string(from: date)
    }
    
    var testSampleCollectionDatePassFormat: String? {
        guard case let COVIDPass.Data.CertificateData.test(t) = data.certificateData,
              let date = DateFormatterCache.shared.iso8601DateFormatter.date(from: t.testSampleCollectionDate) else {
            return nil
        }
        
        return DateFormatterCache.shared.iso8601DateFormatter.string(from: date)
    }
}
