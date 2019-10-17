import Cocoa

var str1 = "Hello, playground"

func albumReleased(year: Int) -> String? {
    switch year {
    case 2006: return "Taylor Swift"
    case 2008: return "Fearless"
    case 2010: return "Speak Now"
    case 2012: return "Red"
    case 2014: return "1989"
    default: return nil
    }
}

let album = albumReleased(year: 2006)
print("The album is \(album)")

let str2 = "Hello World"
print(str2.uppercased())

let album1 = albumReleased(year: 2006)?.uppercased()
print("The album is \(album1)")

let album2 = albumReleased(year: 2006) ?? "unknown"
print("The album is \(album2)")

let names = ["John", "Paul", "George", "Ringo"]

let beatle = names.first?.uppercased()
