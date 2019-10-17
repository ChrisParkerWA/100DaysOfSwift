//
//  ViewController.swift
//  P12BNamesToFaces
//
//  Created by Chris Parker on 16/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Names To Faces"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        picker.delegate = self
        
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch {
                print("Failed to load people")
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename or Delete", message: "Key in a new description and click rename.", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "Delete Entry", style: .destructive) { [weak self] _ in
            self?.people.remove(at: indexPath.row)
            self?.save()
            collectionView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac!.textFields?[0].text else { return }
            if newName != "" {
                person.name = newName
            }
            self?.save()
            self?.collectionView?.reloadData()
        })
        
        present(ac, animated: true)
    }
    
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
         
//        picker.allowsEditing = true   //  Allows an edited image to be selected (cropped)
        
    }
    
    func cameraSelected() {
        picker.sourceType = .camera
//        picker.allowsEditing = true   //  Allows an edited image to be selected (cropped)
//        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func photosSelected() {
        picker.sourceType = .photoLibrary
//        picker.allowsEditing = true   //  Allows an edited image to be selected (cropped)
//        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("The picker didFinishPickingMediaWithInfo")
        guard let image = info[.originalImage] as? UIImage else { return }
        //  Change .originalImage to .editedImage depending on your taste.
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else {
            print("Failed to save people.")
        }
    }
    
}

