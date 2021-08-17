//
//  PassBuilder+Convenience.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 17/08/2021.
//

extension PassBuilder.GeneratedPassData {
    
    var filename: String {
        switch type {
        case .recovery:
            return "\(name) - Recuperacao.pkpass"
        case .test:
            return "\(name) - Testagem.pkpass"
        case .vaccination:
            return "\(name) - Vacinacao.pkpass"
        }
    }
}
