import Vapor

func routes(_ app: Application) throws {
    
    try app.register(collection: MXQController())
    try app.register(collection: AlertController())
}
