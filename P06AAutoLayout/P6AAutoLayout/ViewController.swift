//
//  ViewController.swift
//  P6AAutoLayout
//
//  Created by Chris Parker on 3/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var totalQuestions = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["argentinia", "australia", "bolivia", "brazil", "canada","chile", "china", "denmark", "egypt", "estonia", "finland", "france", "germany", "greece", "iraq", "ireland", "israel", "italy", "jamaica", "japan", "malaysia", "mexico", "monaco", "namibia", "new zealand", "nigeria", "poland", "russia", "south korea", "spain", "uk", "us" ]
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        askQuestion()
    }
    
    func askQuestion(action: UIAlertAction! = nil ) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        totalQuestions += 1
        
        title = countries[correctAnswer].uppercased() + " - Score: \(score)"
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var vcTitle: String
        var message: String = ""
        var actionTitle: String = ""
        
        if sender.tag == correctAnswer {
            vcTitle = "Correct"
            score += 1
        } else {
            vcTitle = "Wrong, that's the flag of \(countries[sender.tag].uppercased())"
            score -= 1
        }
        
        if totalQuestions < 10 {
            message = "Your score is \(score)/\(totalQuestions)"
            actionTitle = "Continue"
        } else {
            message = "Your final score is \(score)/\(totalQuestions)"
            actionTitle = "New Game?"
            score = 0
            totalQuestions = 0
        }
        
        let ac = UIAlertController(title: vcTitle, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
}

