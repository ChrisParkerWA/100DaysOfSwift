import Cocoa

//  We can provide our own initializer to replace the default one. For example, we might want to create all new users as “Anonymous” and print a message, like this:

struct User {
    var username: String
    
    init() {
        username = "Anonymous"
        print("Creating a new user!")
    }
}
//  You don’t write func before initializers, but you do need to make sure all properties have a value before the initializer ends.

//  Now our initializer accepts no parameters, we need to create the struct like this:

var user = User()
user.username = "twostraws"
