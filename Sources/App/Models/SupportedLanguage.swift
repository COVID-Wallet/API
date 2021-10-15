//
//  SupportedLanguage.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 15/10/2021.
//

enum SupportedLanguage {
    
    case english
    case portuguese
    
    init?(rawValue: String?) {
        switch rawValue {
        case "PT":
            self = .portuguese
        case "EN":
            self = .english
        default:
            return nil
        }
    }
}
