import Cocoa


//  Access control lets you restrict which code can use properties and methods. This is important because you might want to stop people reading a property directly, for example.

//    We could create a Person struct that has an id property to store their social security number:

struct Person {
    var id: String
    
    init(id: String) {
        self.id = id
    }
}

let ed = Person(id: "12345")

//  Once that person has been created, we can make their id be private so you can’t read it from outside the struct – trying to write ed.id simply won’t work.

//  Just use the private keyword, like this:


struct Person1 {
    private var id: String
    
    init(id: String) {
        self.id = id
    }
}

let ed1 = Person(id: "12345")


//  Now only methods inside Person can read the id property. For example:

struct Person2 {
    private var id: String
    
    init(id: String) {
        self.id = id
    }
    
    func identify() -> String {
        return "My social security number is \(id)"
    }
}

let ed2 = Person(id: "12345")

print(ed2.id)

//  Another common option is public, which lets all other code use the property or method.





//  Access control lets you specify what data inside structs and classes should be exposed to the outside world, and you get to choose four modifiers:

//  Public: this means everyone can read and write the property.
//  Internal: this means only your Swift code can read and write the property. If you ship your code as a framework for others to use, they won’t be able to read the property.
//  File Private: this means that only Swift code in the same file as the type can read and write the property.
//  Private: this is the most restrictive option, and means the property is available only inside methods that belong to the type, or its extensions.
//  Most of the time you don't need to specify access control, but sometimes you'll want to explicitly set a property to be private because it stops others from accessing it directly. This is useful because your own methods can work with that property, but others can't, thus forcing them to go through your code to perform certain actions.

//  To declare a property private, just do this:

class TaylorFan {
    private var name: String!
}

//  If you want to use “file private” access control, just write it as one word like so: fileprivate. I should say, though, that fileprivate is used pretty rarely!

