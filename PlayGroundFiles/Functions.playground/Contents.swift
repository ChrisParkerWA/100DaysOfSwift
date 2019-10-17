import Cocoa

var str = "Hello, playground"


//func makeSandwich(fillings String...) {
//    print("I'm making a sandwich...")
//    for filling in fillings {
//        print("Let's add some \(filling).")
//    }
//}
//
//makeSandwich("lettuce","tomato","Onion")

//enum SwimmingError: Error {
//    case cantSwim
//}
//func swim(distance: Int) {
//    throw SwimmingError.cantSwim
//}


func driveCar(_ type: String) {
    print("I'm test driving a \(type)")
}
driveCar("Ferrari")


enum ReadingErrors: Error {
    case tooBoring
}
func readBook(isFiction: Bool = true) throws {
    if isFiction {
        print("Story time!")
    } else {
        throw ReadingErrors.tooBoring
    }
}

func play(games: String...) {
    for game in games {
        print("Let's play \(game)!")
    }
}
play(games: "Chess", "poker", "golf")


