import Cocoa


//  As a performance optimization, Swift lets you create some properties only when they are needed. As an example, consider this FamilyTree struct – it doesn’t do much, but in theory creating a family tree for someone takes a long time:

struct FamilyTree {
    init() {
        print("Creating family tree!")
    }
}
//  We might use that FamilyTree struct as a property inside a Person struct, like this:

struct Person {
    var name: String
    lazy var familyTree = FamilyTree()
    
    init(name: String) {
        self.name = name
    }
}

var ed = Person(name: "Ed")
//  But what if we didn’t always need the family tree for a particular person? If we add the lazy keyword to the familyTree property, then Swift will only create the FamilyTree struct when it’s first accessed:

//lazy var familyTree = FamilyTree()
//  So, if you want to see the “Creating family tree!” message, you need to access the property at least once:

ed.familyTree

