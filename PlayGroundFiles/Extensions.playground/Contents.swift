import Cocoa


//  Extensions allow you to add methods to existing types, to make them do things they weren’t originally designed to do.

//  For example, we could add an extension to the Int type so that it has a squared() method that returns the current number multiplied by itself:

extension Int {
    func squared() -> Int {
        return self * self
    }
}

//  To try that out, just create an integer and you’ll see it now has a squared() method:

let number = 8
number.squared()

//  Swift doesn’t let you add stored properties in extensions, so you must use computed properties instead. For example, we could add a new isEven computed property to integers that returns true if it holds an even number:

extension Int {
    var isEven: Bool {
        return self % 2 == 0
    }
}

let thisNumber = 8
thisNumber.isEven

extension Int {
    var isAnswerToLifeUniverseAndEverything: Bool {
        self == 42
    }
}

extension Bool {
    func toggled() -> Bool {
        if self = true {
            return false
        } else {
            return true
        }
    }
}

extension String {
    func withPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) { return self }
        return "\(prefix)\(self)"
    }
}

extension Int {
    times(_ action: () -> Void) {
        for _ in 0..<self {
            action()
        }
    }
}

extension String {
    func isUppercased() -> Bool {
        return self == self.uppercased()
    }
}

extension Int {
    func clamped(min: Int, max: Int) -> Int {
        if (self > max) {
            return max
        } else if (self < min) {
            return min
        }
        return self
    }
}

ext Array {
    func summarize() {
        print("The array has \(count) items. They are:")
        for item in self {
            print(item)
        }
    }
}

extension Double {
    var isNegative: Bool {
        return self < 0
    }
}

extension String {
    var isLong: Bool {
        return count > 25
    }
}
