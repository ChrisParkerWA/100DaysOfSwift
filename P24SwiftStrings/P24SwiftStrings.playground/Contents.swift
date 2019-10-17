import UIKit

var str = "Hello, playground"

let name = "Taylor"

for letter in name {
    print("Give me a \(letter)!")
}


let letter = name[name.index(name.startIndex, offsetBy: 3)]

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

let letter2 = name[3]


let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

extension String {
    // remove a prefix if it exists
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    // remove a suffix if it exists
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

let weather = "it's going to rain"
print(weather.capitalized)

extension String {
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

let input = "Swift is like Objective-C without the C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        
        return false
    }
}

input.containsAny(of: languages)


languages.contains(where: input.contains)


let string = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]

let attributedString = NSAttributedString(string: string, attributes: attributes)

let attributedString1 = NSMutableAttributedString(string: string)
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

/*
 There are lots of formatting options for attributed strings, including:
 
 Set .underlineStyle to a value from NSUnderlineStyle to strike out characters.
 Set .strikethroughStyle to a value from NSUnderlineStyle (no, that’s not a typo) to strike out characters.
 Set .paragraphStyle to an instance of NSMutableParagraphStyle to control text alignment and spacing.
 Set .link to be a URL to make clickable links in your strings.
 And that’s just a subset of what you can do.
 */

//   CHALLENGE:
/* 1. Create a String extension that adds a withPrefix() method. If the string already contains the prefix it should return itself; if it doesn’t contain the prefix, it should return itself with the prefix added. For example: "pet".withPrefix("car") should return “carpet”.
 */

extension String {
    func withPrefix(_ prefix: String) -> String {
        guard !self.hasPrefix(prefix) else { return self }
        return String(prefix + self)
    }
}

print("pet".withPrefix("car"))
print("carpet".withPrefix("car"))

/*
    2. Create a String extension that adds an isNumeric property that returns true if the string holds any sort of number. Tip: creating a Double from a String is a failable initializer.
 */

extension String {
    func isNumeric() -> Bool {
        return Double(self) != nil
    }
}

print("123".isNumeric())
print("ABC".isNumeric())
print("A123".isNumeric())
print("pi".isNumeric())
print("3.14".isNumeric())


/*  3. Create a String extension that adds a lines property that returns an array of all the lines in a string. So, “this\nis\na\ntest” should return an array with four elements.
 */

extension String {
    func lines() -> [String] {
        return self.components(separatedBy: "\n")
    }
}

print("this\nis\na\ntest".lines())
print("this\nis\na\ntest".lines().count)

let poem = """
And then the day came,
when the risk
to remain tight
in a bud
was more painful
than the risk
it took
to blossom.
"""
print(poem.lines())
print("This text contains \(poem.lines().count) lines.")

