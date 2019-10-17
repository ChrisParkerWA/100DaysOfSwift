import Cocoa


func process(order: String) {
    print("OK, I'll get your \(order).")
}
let pizzaRequest: String! = "pizza"
process(order: pizzaRequest)


//func brewBeer(to strength: Double?) {
//    guard strength = strength else { return }
//    print("Let's brew some beer!")
//}
//brewBeer(to: 5.5)

func mowGrass(to height: Double?) {
    guard let height = height else { return }
    print("Mowing the grass to \(height).")
}
mowGrass(to: 6.0)


//enum NetworkError: Error {
//    case insecure
//    case noWifi
//}
//func downloadData(from url: String) -> String {
//    if url.hasPrefix("https://") {
//        return "This is the best Swift site ever!"
//    } else {
//        throw NetworkError.insecure
//    }
//}
//
//if let data = try? downloadData(from: "https://www.hackingwithswift.com") {
//    print(data)
//} else {
//    print("Unable to fetch the data.")
//}
//
//struct Furniture { }
//struct DeckChair: Furniture { }
//let chair = DeckChair()
//if let furniture = chair as? Furniture {
//    print("This is furniture.")
//}
//
//let doctor: String? = "Dr Singh"
//let assignedDoctor: String = doctor?





