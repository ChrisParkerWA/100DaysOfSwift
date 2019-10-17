//
//  ViewController.swift
//  P2GuessFlag
//
//  Created by Chris Parker on 27/2/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var highScore = 0
    var correctAnswer = 0
    var totalQuestions = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showScore))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(showScore))
        
        countries += ["argentinia", "australia", "bolivia", "brazil", "canada","chile", "china", "denmark", "egypt", "estonia", "finland", "france", "germany", "greece", "iraq", "ireland", "israel", "italy", "jamaica", "japan", "malaysia", "mexico", "monaco", "namibia", "new zealand", "nigeria", "poland", "russia", "south korea", "spain", "uk", "us" ]
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        highScore = UserDefaults.standard.integer(forKey: "score")
        
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
    
    @objc func showScore() {
        let ac = UIAlertController(title: "Your score is", message: "Score: \(score)/\(totalQuestions - 1)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        ac.addAction(okAction)
        present(ac, animated: true)
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var vcTitle: String
        var message: String = ""
        var actionTitle: String = ""
        
        //  Challenge 3 from Day 58: Animate flag with scaling when selected.
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (success) in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                sender.transform = .identity
            })
        }
        
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
            //  Retrieve previously saved high score.
            highScore = UserDefaults.standard.integer(forKey: "score")
            if score > highScore {
                message = "Your final score is \(score)/\(totalQuestions) and beat your previous score of \(highScore)"
                UserDefaults.standard.set(score, forKey: "score")
            } else {
                message = "Your final score is \(score)/\(totalQuestions)"
                UserDefaults.standard.set(score, forKey: "score")
            }
            
            actionTitle = "New Game?"
            score = 0
            totalQuestions = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            let ac = UIAlertController(title: vcTitle, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: self.askQuestion))
            self.present(ac, animated: true)
        }
        
    }
    
}

