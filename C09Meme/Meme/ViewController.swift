//
//  ViewController.swift
//  Meme
//
//  Created by Chris Parker on 14/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: UIImage?
    var memeTopText: String?
    var memeBottomText: String?
    var isPhotoAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "Meme Generator"
        
        
        let addImage = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(selectImage))
        let shareMeme = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteImage))
        
        navigationItem.leftBarButtonItem = delete
        navigationItem.rightBarButtonItems = [addImage]
        
        let topCaption = UIBarButtonItem(title: "Top Caption", style: .plain, target: self, action: #selector(addTopCaption))
        let bottomCaption = UIBarButtonItem(title: "Bottom Caption", style: .plain, target: self, action: #selector(addBottomCaption))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbarItems = [topCaption, space, bottomCaption, space, shareMeme]
        navigationController?.isToolbarHidden = false
        self.view.backgroundColor = UIColor(displayP3Red:0.878, green: 0.992, blue: 0.722, alpha: 1.0)
        
        memeTopText = ""
        memeBottomText = ""
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true     //  For .originalImages, comment out this line.
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        //  Change .editedImages to .originalImage depending on your taste
        selectedImage = image
        dismiss(animated: true)
        isPhotoAdded = true
        updateImage()
    }
    
    @objc func shareTapped() {
        //  Convert image into a compressed jpeg
        guard isPhotoAdded else {
            showAlert("No image selected", message: nil, buttonText: "OK")
            return
        }
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            showAlert("No image found.", message: nil, buttonText: "OK")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true) {
            //  Gives enough time for the Activity View Controller to complete.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.showAlert("Image shared", message: nil, buttonText: "OK")
            })
        }
    }
    
    @objc func deleteImage() {
        selectedImage = nil
        memeTopText = ""
        memeBottomText = ""
        updateImage()
        isPhotoAdded = false
        showAlert("Renderer reset", message: "Ready to create another meme.\nPress the + button to add a new image.", buttonText: "OK")
    }
    
    func showAlert(_ title: String, message: String?, buttonText: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: buttonText, style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    @objc func addTopCaption() {
        let ac = UIAlertController(title: "Top Caption", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter Caption"
            textField.autocapitalizationType = .allCharacters
            textField.font = UIFont.systemFont(ofSize: 14)
        }
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak ac, weak self] _ in
            guard let text = ac?.textFields?[0].text else { return }
            self?.memeTopText = text
            self?.updateImage()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func addBottomCaption() {
        let ac = UIAlertController(title: "Bottom Caption", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter Caption"
            textField.autocapitalizationType = .allCharacters
            textField.font = UIFont.systemFont(ofSize: 14)
        }
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak ac, weak self] _ in
            guard let text = ac?.textFields?[0].text else { return }
            self?.memeBottomText = text
            self?.updateImage()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func updateImage() {
        // Create a renderer at the correct size.
        let renderer = UIGraphicsImageRenderer(size: imageView.frame.size)
        
        let renderedImage = renderer.image { ctx in
            
            //  Insert image   - imageView.frame.size.width
            selectedImage?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
            
            // Define a paragraph style that aligns text to the center.
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = .zero
            
            // Create an attributes dictionary containing that paragraph style, and also a font.
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Roboto-Black", size: 28)!,
                .foregroundColor: UIColor.white,
                .strokeWidth : -3.0,
                .strokeColor: UIColor.black,
                .paragraphStyle: paragraphStyle,
            ]
            // Wrap that attributes dictionary and a string into an instance of NSAttributedString.
            if let memeTopText = memeTopText {
                let topAttributedString = NSAttributedString(string: memeTopText, attributes: attrs)
                topAttributedString.draw(with: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: 200), options: .usesLineFragmentOrigin, context: nil)
            }
            
            var heightAdjust: CGFloat = 0
            switch memeBottomText!.count {
            case 0...20:
                heightAdjust = 34
            case 21...40:
                heightAdjust = 68
            case 41...60:
                heightAdjust = 102
            default:
                heightAdjust = 136
            }
            if memeBottomText!.count < 18 {
                //  Insert a line break as the first character
            }

            if let memeBottomText = memeBottomText {
                let bottomAttributedString = NSAttributedString(string: memeBottomText, attributes: attrs)
                bottomAttributedString.draw(with: CGRect(x: 0, y: imageView.frame.size.height - heightAdjust, width: imageView.frame.size.width, height: 220), options: .usesLineFragmentOrigin, context: nil)
            }
        }
        imageView.image = renderedImage
    }

}

