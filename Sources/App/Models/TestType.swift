//
//  TestType.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

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
    
    func name(language: SupportedLanguage) -> String {
        switch self {
        case .pcr:
            switch language {
            case .english:
                return "PCR Test"
            case .portuguese:
                return "Teste PCR"
            }
            
        case .rapid:
            switch language {
            case .english:
                return "Rapid Test"
            case .portuguese:
                return "Teste Rápido"
            }
        }
    }
}
