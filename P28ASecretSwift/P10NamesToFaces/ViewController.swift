//
//  ViewController.swift
//  P10NamesToFaces
//
//  Created by Chris Parker on 16/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    var picker = UIImagePickerController()
    //  Challenge 3: Add code to facilitate user authentication
    var peopleDisplay = [Person]()  //  people array for display in tableView
    var password: String?
    var userAuthenticated = false
    var authButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Names To Faces"
        picker.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        //  Challenge 3: Add code to facilitate user authentication
        authButton = UIBarButtonItem(title: "Authenticate", style: .plain, target: self, action: #selector(authenticateUser))
        navigationItem.rightBarButtonItems = [authButton]
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(lockScreen), name: UIApplication.willResignActiveNotification, object: nil)
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peopleDisplay.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let person = peopleDisplay[indexPath.item]
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
      
        cell.name.text = person.name
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let person = peopleDisplay[indexPath.item]
        
        let ac = UIAlertController(title: "Rename or Delete", message: "Key in a new description and click rename.", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "Delete Entry", style: .destructive) { [weak self] _ in
            self?.people.remove(at: indexPath.row)
            self?.peopleDisplay = self!.people
            collectionView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac!.textFields?[0].text else { return }
            if newName != "" {
                person.name = newName
            }
            
            self?.collectionView?.reloadData()
        })
        
        present(ac, animated: true)
    }
    
    //  MARK:  Begin: User Authentication section
    @objc func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self ] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockScreen()
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
    
    func unlockScreen() {
        userAuthenticated = true
        navigationItem.rightBarButtonItems = []
        peopleDisplay = people
        collectionView.reloadData()
    }
    
    @objc func lockScreen() {
        userAuthenticated = false
        navigationItem.rightBarButtonItems = [authButton]
        peopleDisplay.removeAll()
        collectionView.reloadData()
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
                    self?.unlockScreen()
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
                self?.unlockScreen()
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
    //  MARK:  End: User Authentication section
    
    @objc func addNewPerson() {
        
        let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        if cameraAvailable {
            // Give user the choice of selecting either the camera or the photoLibrary
            let ac = UIAlertController(title: "Camera or PhotoLibrary", message: nil, preferredStyle: .alert)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { [ weak self ] _ in
                print("Camera selected")
                self?.cameraSelected()
            }
            let photos = UIAlertAction(title: "Photo Library", style: .cancel) { [ weak self ] _ in
                print("PhotoLibrary selected")
                self?.photosSelected()
            }
            print(picker.sourceType)
            ac.addAction(camera)
            ac.addAction(photos)
            present(ac, animated: true)
            
        } else {
            photosSelected()
        }
        
    }
    
    func cameraSelected() {
        picker.sourceType = .camera
//        picker.allowsEditing = true   //  Allows an edited image to be selected (cropped)
        present(picker, animated: true)
    }
    
    func photosSelected() {
        picker.sourceType = .photoLibrary
//        picker.allowsEditing = true   //  Allows an edited image to be selected (cropped)
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        //  Change .originalImage to .editedImage depending on if you want the user to be able to crop the image.
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        peopleDisplay = people
    
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
}

