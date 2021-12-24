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
        guard surnames.count > 0 else {
            return forenames.capitalized
        }
        
        return [forenames.components(separatedBy: " ").first, surnames.components(separatedBy: " ").last]
            .compactMap { $0 }
            .joined(separator: " ")
            .capitalized
    }
    
    var fullName: String {
        [forenames, surnames]
            .joined(separator: " ")
            .capitalized
    }
}
