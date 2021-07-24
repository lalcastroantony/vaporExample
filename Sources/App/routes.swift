import Vapor

struct Greeting: Content {
    var hello: String
}
struct Hello: Content {
    var name: String?
}

func routes(_ app: Application) throws {
    addRoutes(app)
    let users = app.grouped("users")
    // GET /users
    users.get { req in
        return "users.get"
    }
    // POST /users
    users.post { req in
        return "users.post"
    }
    // GET /users/:id
    users.get(":id") { req -> String in
        let id = req.parameters.get("id")!
        return "users.get \(id)"
    }
    
    app.get("greeting") { req -> HTTPStatus in
        let greeting = try req.content.decode(Greeting.self)
        print(greeting.hello) // "world"
        return HTTPStatus.ok
    }
    app.get("hello") { req -> String in
        let hello = try req.query.decode(Hello.self)
        return "Hello, \(hello.name ?? "Anonymous")"
    }
    app.get("html") { req -> EventLoopFuture<View> in
        let dir = DirectoryConfiguration.detect()
        let path = dir.publicDirectory + "index.html"
        print("path of html: \(path)")
        return req.view.render(path)
    }
    app.get("documentation") { req -> EventLoopFuture<View> in
        let dir = DirectoryConfiguration.detect()
        let path = dir.publicDirectory + "MyLibrary.doccarchive/index.html"
        print("path of html: \(path)")
        return req.view.render(path)
    }
}



func addRoutes(_ app: Application) {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    app.get("hello", "vapor") { req in
        return "Hello, vapor!"
    }
    app.get("hello", ":name") { req -> String in
        let name = req.parameters.get("name")!
        return "Hello, \(name)!"
    }.description("says hello")
    // responds to OPTIONS /foo/bar/baz
    //on function that accepts HTTP method as an input parameter.
    app.on(.OPTIONS, "foo", "bar", "baz") { req -> String in
        switch req.method {
        case .GET:
        return "on get"
        default:
            return "not get"
        }
    }
    
    app.get("foo", "*", "baz") { req in
        return "foo * baz"
    }
    // responds to GET /foo/bar
    // responds to GET /foo/bar/baz
    // ...
    app.get("foo", "**") { req in
        return "foo, **"
    }
    // responds to GET /number/42
    // responds to GET /number/1337
    // ...
    app.get("number", ":x") { req -> String in
        guard let int = req.parameters.get("x", as: Int.self) else {
            throw Abort(.badRequest)
        }
        return "\(int) is a great number"
    }
    
    // responds to GET /hello/foo
    // responds to GET /hello/foo/bar
    // ...
    app.get("hello", "**") { req -> String in
        let name = req.parameters.getCatchall().joined(separator: " ")
        return "Hello, \(name)!"
    }
    // Collects streaming bodies (up to 1mb in size) before calling this route.
    app.on(.POST, "listings", body: .collect(maxSize: "1mb")) { req in
        return "listings"
    }
    
    // Request body will not be collected into a buffer.
    app.on(.POST, "upload", body: .stream) { req in
        return "upload"
    }
}


