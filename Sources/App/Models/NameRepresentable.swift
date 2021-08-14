//
//  NameRepresentable.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

import Foundation

protocol NameRepresentable {
    
    var forenames: String { get }
    var surnames: String { get }
}

extension NameRepresentable {
    
    var shortName: String {
        forenames.capitalized
    }
    
    var fullName: String {
        [forenames, surnames].reduce("") {
            guard $0 != "" else {
                return $1
            }
            
            return "\($0) \($1)"
        }.capitalized
    }
}
