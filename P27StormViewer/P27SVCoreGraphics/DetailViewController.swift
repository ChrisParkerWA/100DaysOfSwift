//
//  DetailViewController.swift
//  P27SVCoreGraphics
//
//  Created by Chris Parker on 28/2/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: String?
    var totalPictures: Int = 0
    var selectImageNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Picture \(selectImageNumber) of \(totalPictures)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.largeTitleDisplayMode = .never
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
        
        renderImageAndText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image, selectedImage!], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    //  Challenge 3 from Core Graphics 
    func renderImageAndText() {
        // 1  Create a renderer at the correct size.
        
        // 5  Load an image from the project and extract image sizes
        let stormImage = UIImage(named: selectedImage!)
        let imageWidth = stormImage!.size.width
        let imageHeight = stormImage!.size.height
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: imageWidth, height: imageHeight))
        
        let renderedImage = renderer.image { ctx in
            
            // 2  Define a paragraph style that aligns text to the center.
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // 3  Create an attributes dictionary containing that paragraph style, and also a font.
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "HelveticaNeue", size: 72)!,
                .paragraphStyle: paragraphStyle,
                .backgroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
            ]
            
            // 4  Wrap that attributes dictionary and a string into an instance of NSAttributedString.
            let string = "From Storm Viewer"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
           
            //  Draw image to the context.  Origin is top left corner of renderer rectangle.

            stormImage?.draw(at: CGPoint(x: 0, y: 0))
            
             // 6  Update the image view with the finished result.
            attributedString.draw(with: CGRect(x: self.view.frame.width / 2, y: self.view.frame.width / 4, width: self.view.frame.width * 2, height: self.view.frame.width * 2), options: .usesLineFragmentOrigin, context: nil)
            
        }
        imageView.image = renderedImage
        imageView.contentMode = .scaleAspectFit
    }

}
