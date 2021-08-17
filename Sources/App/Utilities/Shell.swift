//
//  Shell.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 17/08/2021.
//

import Foundation

enum Shell {
    
    static func execute(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
