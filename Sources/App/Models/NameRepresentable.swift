//
//  NameRepresentable.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 14/08/2021.
//

protocol NameRepresentable {
    
    var forenames: String { get }
    var surnames: String { get }
}

extension NameRepresentable {
    
    var shortName: String {
        forenames.capitalized
    }
    
    var fullName: String {
        [forenames, surnames]
            .joined(separator: " ")
            .capitalized
    }
}
