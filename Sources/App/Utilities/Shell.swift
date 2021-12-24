//
//  Shell.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 17/08/2021.
//

import Foundation

enum Shell {
    
    enum CommandExecutionError: Error {
        
        case noAcceptableShell
    }
    
    static var shellPath: String? {
        if FileManager.default.isExecutableFile(atPath: "/bin/zsh") {
            return "/bin/zsh"
        } else if FileManager.default.isExecutableFile(atPath: "/bin/sh") {
            return "/bin/sh"
        } else if FileManager.default.isExecutableFile(atPath: "/usr/bin/zsh") {
            return "/usr/bin/zsh"
        } else if FileManager.default.isExecutableFile(atPath: "/usr/bin/sh") {
            return "/usr/bin/sh"
        }
        
        return nil
    }
    
    static func execute(_ command: String) throws -> String {
        guard let shellPath = shellPath else {
            throw CommandExecutionError.noAcceptableShell
        }
        
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: shellPath)
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
