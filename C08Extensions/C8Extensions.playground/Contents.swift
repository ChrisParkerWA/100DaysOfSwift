import UIKit
import PlaygroundSupport

let container = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 250))
container.backgroundColor = .darkGray
PlaygroundPage.current.liveView = container

// extension 1: animate out a UIView
extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

// extension 2: create a times() method for integers
extension Int {
    func times(_ closure: () -> Void) {
        guard self > 0 else { return }
        
        for _ in 0 ..< self {
            closure()
        }
    }
}

// extension 3: remove an item from an array
extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        if let location = self.firstIndex(of: item) {
            self.remove(at: location)
        }
    }
}

// some test code to make sure everything works
let view = UIView(frame: CGRect(x: 150, y: 25, width: 200, height: 200))
view.layer.cornerRadius = 100
view.backgroundColor = .green
container.addSubview(view)
view.bounceOut(duration: 3)

5.times { print("Hello") }

var numbers = [1, 2, 3, 3, 3, 4, 4, 5]
numbers.remove(item: 4)
