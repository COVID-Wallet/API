//
//  TestType.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

import Foundation

enum TestType {
    
    case pcr
    case rapid
    
    init?(code: String) {
        switch code {
        case "LP6464-4":
            self = .pcr
        case "LP217198-3":
            self = .rapid
        default:
            return nil
        }
    }
    
    var name: String {
        //  TODO: Check these values.
        
        switch self {
        case .pcr:
            return "Teste PCR"
        case .rapid:
            return "Teste Rápido"
        }
    }
}
