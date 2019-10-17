import Cocoa

/*
Classes are similar to structs in that they allow you to create new types with properties and methods, but they have five important differences and I’m going to walk you through each of those differences one at a time.

The first difference between classes and structs is that classes never come with a memberwise initializer. This means if you have properties in your class, you must always create your own initializer.

For example:
*/

class Dog {
    var name: String
    var breed: String
    
    init(name: String, breed: String) {
        self.name = name
        self.breed = breed
    }
}

//  Creating instances of that class looks just the same as if it were a struct:

let poppy = Dog(name: "Poppy", breed: "Poodle")

print(poppy.name, poppy.breed)

//  We could create a new class based on that one called Poodle. It will inherit the same properties and initializer as Dog by default:

//  However, we can also give Poodle its own initializer. We know it will always have the breed “Poodle”, so we can make a new initializer that only needs a name property. Even better, we can make the Poodle initializer call the Dog initializer directly so that all the same setup happens:

class Poodle: Dog {
    init(name: String) {
        super.init(name: name, breed: "Poodle")
    }
}

//  For safety reasons, Swift always makes you call super.init() from child classes – just in case the parent class does some important work when it’s created.

