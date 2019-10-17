import Cocoa



class Dog {
    func makeNoise() {
        print("Woof!")
    }
}
//  Method overriding allows us to change the implementation of makeNoise() for the Poodle class.

//  Swift requires us to use override func rather than just func when overriding a method – it stops you from overriding a method by accident, and you’ll get an error if you try to override something that doesn’t exist on the parent class:

class Poodle: Dog {
    override func makeNoise() {
        print("Yip!")
    }
}
//  With that change, poppy.makeNoise() will print “Yip!” rather than “Woof!”.

let poppy = Poodle()
poppy.makeNoise()

