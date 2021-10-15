//
//  WalletPassGeneratorController.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 09/08/2021.
//

import Vapor

final class WalletPassGeneratorController {
    
    enum RequestError: Error {
        
        case noBody
    }
    
    enum ResponseError: Error {
    
        case badEnvironment
    }
    
    private func getQRCodeData(_ req: Request) throws -> String {
        do {
            return try req.content.get(String.self, at: "data")
        } catch {
            guard let qcd = req.body.string else {
                throw RequestError.noBody
            }
            
            return qcd
        }
    }
    
    func generate(_ req: Request) throws -> Response {
        guard let certificateKey = Environment.get(EnvironmentKey.certificateKey.rawValue),
              let passTypeIdentifier = Environment.get(EnvironmentKey.passTypeIdentifier.rawValue),
              let teamIdentifier = Environment.get(EnvironmentKey.teamIdentifier.rawValue) else {
            throw ResponseError.badEnvironment
        }
        
        let qrCodeData = try getQRCodeData(req)
        
        let dosesOverride = try? req.content.get(String.self, at: "dosesOverride")
        let languageOverride = try? req.content.get(String.self, at: "languageOverride")
        let shortNameOverride = try? req.content.get(String.self, at: "shortNameOverride")
        
        let overrides = PassBuilder.Overrides(doses: dosesOverride != "" ? dosesOverride : nil,
                                              language: SupportedLanguage(rawValue: languageOverride) ?? nil,
                                              shortName: shortNameOverride != "" ? shortNameOverride : nil)
        
        let passBuilder = PassBuilder(withPass: try QRCodeParser.parse(qrCodeData),
                                      qrCodeData: qrCodeData,
                                      resourcesDirectory: req.application.directory.resourcesDirectory,
                                      teamIdentifier: teamIdentifier,
                                      passTypeIdentifier: passTypeIdentifier,
                                      certificateKey: certificateKey,
                                      overrides: overrides)
        
        try passBuilder.buildUnsignedPass()
        try passBuilder.signPass()
        
        let passURL = try passBuilder.zipPass()
        
        req.eventLoop.scheduleTask(in: .seconds(5)) { passBuilder.cleanup() }
        
        let response = req.fileio.streamFile(at: passURL.path)
        
        response.headers.contentType = .zip
        response.headers.contentDisposition = HTTPHeaders.ContentDisposition(.attachment,
                                                                             name: nil,
                                                                             filename: passBuilder.passData?.filename ?? "Pass.pkpass")
        
        return response
    }
}
