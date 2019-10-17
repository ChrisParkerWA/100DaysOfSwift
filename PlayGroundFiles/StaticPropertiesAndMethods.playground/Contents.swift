import Cocoa


//  All the properties and methods we’ve created so far have belonged to individual instances of structs, which means that if we had a Student struct we could create several student instances each with their own properties and methods:

struct Student {
    static var classSize = 0
    var name: String
    
    init(name: String) {
        self.name = name
        Student.classSize += 1
    }
}

let ed = Student(name: "Ed")
let taylor = Student(name: "Taylor")
//  You can also ask Swift to share specific properties and methods across all instances of the struct by declaring them as static.

//  To try this out, we’re going to add a static property to the Student struct to store how many students are in the class. Each time we create a new student, we’ll add one to it:

//  Because the classSize struct belongs to the struct itself rather than instances of the struct, we need to read it using Student.classSize:

print(Student.classSize)


//  Swift lets you create properties and methods that belong to a type, rather than to instances of a type. This is helpful for organizing your data meaningfully by storing shared data.

//  Swift calls these shared properties "static properties", and you create one just by using the static keyword. Once that's done, you access the property by using the full name of the type. Here's a simple example:

struct TaylorFan {
    static var favoriteSong = "Look What You Made Me Do"
    
    var name: String
    var age: Int
}

let fan = TaylorFan(name: "James", age: 25)
print(TaylorFan.favoriteSong)

//  So, a Taylor Swift fan has a name and age that belongs to them, but they all have the same favorite song.

//  Because static methods belong to the struct itself rather than to instances of that struct, you can't use it to access any non-static properties from the struct.

