import Vapor
import Queues
import QueuesRedisDriver
import XMLCoder
import Leaf

let SWIFT_ENV = Environment.get("SWIFT_ENV") ?? "development"
let env = Environment(name: SWIFT_ENV)

// configures your application
public func configure(_ app: Application) throws {
    
    app.environment = env
    app.logger.notice("Environment: \(app.environment)")
    // uncomment to serve files from /Public folder
    ContentConfiguration.global.use(encoder: XMLEncoder(), for: .init(type: "text", subType: "xml"))
    ContentConfiguration.global.use(decoder: XMLDecoder(), for: .init(type: "text", subType: "xml"))
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.resourcesDirectory))
    app.routes.defaultMaxBodySize = "1mb"
    
    let redisConfig = try RedisConfiguration(hostname: "localhost",
                                             pool: .init(maximumConnectionCount: .maximumActiveConnections(100)))
    app.redis.configuration = redisConfig
    app.queues.use(.redis(redisConfig))
    app.caches.use(.redis)
    
    try database(app)
    try queues(app)

    // register routes
    try routes(app)

    app.views.use(.leaf)

}
