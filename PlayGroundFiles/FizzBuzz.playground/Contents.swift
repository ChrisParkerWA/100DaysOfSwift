import Cocoa


func fizzBuzz(number: Int) -> String {

    if number % 3 == 0 && number % 5 == 0 {
        return "Fizz Buzz"
    } else if number % 3 == 0 {
        return "Fizz"
    } else if number % 5 == 0 {
      return "Buzz"
    }
    return String(number)
}

let result = fizzBuzz(number: 15)
print(result)
