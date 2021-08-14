//
//  TestResult.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

import Foundation

enum TestResult {
    
    case detected
    case notDetected
    
    init?(code: String) {
        switch code {
        case "260415000":
            self = .notDetected
        case "260373001":
            self = .detected
        default:
            return nil
        }
    }
}
