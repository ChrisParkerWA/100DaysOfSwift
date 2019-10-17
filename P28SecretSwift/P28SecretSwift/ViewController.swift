//
//  ViewController.swift
//  P28SecretSwift
//
//  Created by Chris Parker on 16/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    var password: String?
    var done: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here!"
        print("\nPassword in simulator is 'dogsbreath'\n")
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItems = [done]
        
        //  At start up, remove the right Navigation Button Item
        navigationItem.rightBarButtonItems = []
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self ] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        //  error authenticating
                        self?.showAlert("Authentication failed", message: "You could not be verified; please try again", buttonText: "OK")
                    }
                }
            }
            
        } else {
            // No biometry.   Password option offerred
            passwordAuthentication()
        }
    }
    
    func passwordAuthentication() {
        
        //  Retrieve password from Keychain
        //  If a password exists then match saved password with that which was entered
        //  else ask user to set one.
        //  Set textfield to isSecureTextEntry = true
        
        password = KeychainWrapper.standard.string(forKey: "Password") ?? ""
        
        if password != "" {
            //  Ask for password
            let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
            ac.addTextField { (textField) in
                textField.placeholder = "password"
                textField.isSecureTextEntry = true
            }
            ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                guard let enteredPassword = ac?.textFields?[0].text else { return }
                //  Test to see if entered password matches stored password
                if enteredPassword == self?.password {
                    self?.unlockSecretMessage()
                } else {
                    // advise password does not match and try again
                    self?.showAlert("Password invalid", message: "Try again", buttonText: "OK")
                }
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            
        } else {
            // Create new password
            let ac = UIAlertController(title: "Create password", message: nil, preferredStyle: .alert)
            ac.addTextField { (textField) in
                textField.placeholder = "password"
                textField.isSecureTextEntry = true
            }
            ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                guard let enteredPassword = ac?.textFields?[0].text else { return }
                //  Code to accept a password and save in Keychain.
                //  No length or alpha/numeric combination requirement checking.
                KeychainWrapper.standard.set(enteredPassword, forKey: "Password")
                self?.unlockSecretMessage()
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
        
    }
    
    func showAlert(_ title: String, message: String?, buttonText: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: buttonText, style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    @objc func doneTapped() {
        saveSecretMessage()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        navigationItem.rightBarButtonItems = [done]
        title = "Secret stuff!"
        
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        navigationItem.rightBarButtonItems = []
        title = "Nothing to see here!"
    }
    
}

