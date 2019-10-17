import Cocoa

var str = "Hello, playground"

let driving = {
    print("I'm driving in my car")
}

func travel(action: () -> Void) {
    print("I'm getting ready to go.")
    action()
    print("I arrived")
}

travel(action: driving)

// Trailing closures
travel() {
    print("I'm drving in my car.")
}

// Because there aren’t any other parameters, we can eliminate the parentheses entirely:
travel {
    print("I'm drving in my car.")
}


let digitNames = [
    0: "Zero", 1: "One", 2: "Two",   3: "Three", 4: "Four",
    5: "Five", 6: "Six", 7: "Seven", 8: "Eight", 9: "Nine"
]
let numbers = [16, 58, 510]

let strings = numbers.map { (number) -> String in
    var number = number
    var output = ""
    repeat {
        output = digitNames[number % 10]! + output
        number /= 10
    } while number > 0
    return output
}
// strings is inferred to be of type [String]
// its value is ["OneSix", "FiveEight", "FiveOneZero"]
print(strings)

func makeIncrementer(forIncrement amount: Int) -> () -> Int {
    var runningTotal = 0
    func incrementer() -> Int {
        runningTotal += amount
        return runningTotal
    }
    return incrementer
}

let incrementByTen = makeIncrementer(forIncrement: 10)
let incrementByFive = makeIncrementer(forIncrement: 5)
incrementByTen()
incrementByTen()
incrementByTen()

incrementByFive()
incrementByFive()
incrementByFive()

