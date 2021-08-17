//
//  WalletPassGeneratorController.swift
//  covid19-pt-apple-wallet-web
//
//  Created by Eduardo Almeida on 09/08/2021.
//

import Foundation

import Vapor

final class WalletPassGeneratorController {
    
    enum RequestError: Error {
        
        case noBody
    }
    
    enum ResponseError: Error {
    
        case badEnvironment
    }
    
    func generate(_ req: Request) throws -> Response {
        guard let certificateKey = Environment.get(EnvironmentKey.certificateKey.rawValue),
              let passTypeIdentifier = Environment.get(EnvironmentKey.passTypeIdentifier.rawValue),
              let teamIdentifier = Environment.get(EnvironmentKey.teamIdentifier.rawValue) else {
            throw ResponseError.badEnvironment
        }
        
        let qrCodeData: String
        
        do {
            qrCodeData = try req.content.get(String.self, at: "data")
        } catch {
            guard let qcd = req.body.string else {
                throw RequestError.noBody
            }
            
            qrCodeData = qcd
        }
        
        var dosesOverride = try? req.content.get(String.self, at: "dosesOverride")
        var shortNameOverride = try? req.content.get(String.self, at: "shortNameOverride")
        
        if dosesOverride == "" {
            dosesOverride = nil
        }
        
        if shortNameOverride == "" {
            shortNameOverride = nil
        }
        
        let covidPass = try QRCodeParser.parse(qrCodeData)
        
        let passBuilder = PassBuilder(withPass: covidPass,
                                      qrCodeData: qrCodeData,
                                      resourcesDirectory: req.application.directory.resourcesDirectory,
                                      teamIdentifier: teamIdentifier,
                                      passTypeIdentifier: passTypeIdentifier,
                                      certificateKey: certificateKey,
                                      overrides: PassBuilder.Overrides(doses: dosesOverride, shortName: shortNameOverride))
        
        try passBuilder.buildUnsignedPass()
        try passBuilder.signPass()
        
        let passURL = try passBuilder.zipPass()
        
        req.eventLoop.scheduleTask(in: .seconds(5)) { passBuilder.cleanup() }
        
        let response = req.fileio.streamFile(at: passURL.path)
        
        response.headers.contentType = .zip
        response.headers.contentDisposition = HTTPHeaders.ContentDisposition(.attachment, name: nil, filename: "Pass.pkpass")
        
        return response
    }
}
