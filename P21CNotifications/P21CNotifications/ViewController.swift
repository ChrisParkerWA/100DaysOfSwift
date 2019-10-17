//
//  ViewController.swift
//  P21CNotifications
//
//  Created by Chris Parker on 27/2/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
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
        
        
        registerNotifications()
        askQuestion()
    }
    
    //  P21 Challenge 3: And for an even harder challenge, update project 2 'Guess the Flags' so that it reminds
    //  players to come back and play every day.
    
    func registerNotifications() {
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [ weak self ] (granted, error) in
            if granted {
                self?.setupNewNotifications()
            } else {
                print("Authorisation denied")
            }
        }
    }
    
    func setupNewNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        let play = UNNotificationAction(identifier: "Play", title: "Play now?", options: .foreground)
        
        let category = UNNotificationCategory(identifier: "reminder", actions: [play], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder to play Guess the Flag"
        content.body = "Don't miss out on your daily challenge."
        content.categoryIdentifier = "reminder"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default  // Can use just .default
        
        //  For the purposes of testing, set the interval to 5 seconds rather than daily (86400 seconds).
        let timeInterval = 5 // 86400
        
        for i in 1...7 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval * i), repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
                
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default Identifier")
                
            case "Play¬":
                showAlert("Welcome back", message: "Time to play a game of Guess the Flag.")
                
            default:
                break
            }
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
    
    func showAlert(_ title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
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
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut , animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (success) in
            sender.transform = .identity
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
        
        let ac = UIAlertController(title: vcTitle, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
}

