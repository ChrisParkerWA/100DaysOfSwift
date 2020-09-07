//
//  TableViewController.swift
//  C4Photos
//
//  Created by Chris Parker on 25/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photos = [Photo]()
    var picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Captions to Photos"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPhoto))
        picker.delegate = self
        
        let defaults = UserDefaults.standard
        
        if let savedPhotos = defaults.object(forKey: "photos") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                photos = try jsonDecoder.decode([Photo].self, from: savedPhotos)
            } catch {
                print("Failed to load photos")
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Photo", for: indexPath) as? PhotoCell else {
            fatalError("Unable to dequeue PhotoCell")
        }
        let photo = photos[indexPath.row]

        cell.caption.text = photo.caption

        let path = getDocumentsDirectory().appendingPathComponent(photo.image)
        cell.photograph.image = UIImage(contentsOfFile: path.path)

        cell.photograph.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.photograph.layer.borderWidth = 2
        cell.photograph.layer.cornerRadius = 5
        cell.photograph.clipsToBounds = true
        cell.layer.cornerRadius = 7
        cell.layer.masksToBounds = true

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let photo = photos[indexPath.row]
            vc.selectedImage = photo.image
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func addNewPhoto() {
        
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
        //        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func photosSelected() {
        picker.sourceType = .photoLibrary
        //        picker.allowsEditing = true   //  Allows an edited image to be selected (cropped)
                picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        guard let image = info[.editedImage] as? UIImage else { return }
        //  Change .originalImage to .editedImage depending on your taste.
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        dismiss(animated: true)
        
    
        let ac = UIAlertController(title: "Add Caption", message: "Key in a new Caption and click OK.", preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac ]_ in
            guard let caption = ac?.textFields?[0].text else { return }
          
            let photo = Photo(image: imageName, caption: caption)
            self?.photos.append(photo)
            self?.save()
            self?.tableView.reloadData()
        })
        
        present(ac, animated: true)
            
        
    }

    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(photos) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "photos")
        } else {
            print("Failed to save photos.")
        }
    }
    
}

