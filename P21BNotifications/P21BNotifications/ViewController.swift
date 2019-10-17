//
//  ViewController.swift
//  P21BNotifications
//
//  Created by Chris Parker on 6/5/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleTapped))
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    @objc func scheduleTapped() {
        scheduleLocal(timeInterval: 5)
    }

    @objc func scheduleLocal(timeInterval: Double) {
        
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default  // Can use just .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        //  Challenge 1: Update the code in didReceive so that it shows different instances of
        //  UIAlertController depending on which action identifer was passed in.
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more....", options: .foreground)
        
        let remind = UNNotificationAction(identifier: "remind", title: "Remind me later", options: .foreground)
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remind], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
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
                
            
            case "show":
               print("Show more information")
                
                //  Challenge 2: For a harder challenge, add a second UNNotificationAction to the alarm
                //  category of project 21. Give it the title “Remind me later”, and make it call
                //  scheduleLocal() so that the same alert is shown in 24 hours.
                //  Lets just make it 10 seconds.
    
            case "remind":
                //  user tapped the "remind me later" button
                //  For testing purposes make ths another 10 seconds rather than 86400 (or 24 hours).
                scheduleLocal(timeInterval: 10)
                
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
    
}

