import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.routes.defaultMaxBodySize = "500kb"
    app.routes.caseInsensitive = true
    let dir = DirectoryConfiguration.detect()
    let path = dir.publicDirectory + "MyLibrary.doccarchive"
    let url = URL.init(fileURLWithPath: path)
    app.middleware.use(VaporDocCMiddleware(archivePath: url))
    
    // register routes
    try routes(app)
    print(app.routes.all)
}
