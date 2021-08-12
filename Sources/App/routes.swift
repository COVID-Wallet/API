import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.post("generate") { req -> Response in
        let controller = WalletPassGeneratorController()
        
        return try controller.generate(req)
    }
}
