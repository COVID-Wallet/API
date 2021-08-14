import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.redirect(to: "//covidwallet.pt")
    }
    
    app.post("generate") { req -> Response in
        let controller = WalletPassGeneratorController()
        
        return try controller.generate(req)
    }
}
