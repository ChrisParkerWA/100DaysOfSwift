//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
    
    var images = [Image]()
    
    var dirty = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reactionist"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        loadData()
        
    }
    
    func loadData() {
        //  Decode the images array from UserDefaults
        if let savedImages = UserDefaults.standard.object(forKey: "images") as? Data {
            let decoder = JSONDecoder()
            if let loadedImages = try? decoder.decode([Image].self, from: savedImages){
                self.images = loadedImages
                
                self.tableView.reloadData()
            }
        } else {
            //  Create the thumbnails (first time the App is run)
            createThumbnailData()
        }
        
    }
    
    func createThumbnailData() {
        
        let fm = FileManager.default
        
        //  Get a list of all the files in the App Bundle.
        if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
            //  If Files are found in the App folder then loop through the list
            for item in tempItems {
                //  For each file in the folder, if the filename contains 'Large' (4000 x 4000) then
                if item.range(of: "Large") != nil {
                    //  append that item to the array
                    
                    let object = Image(filename: item, imageName: generateThumbnailImage(item: item))
                    images.append(object)
                }
            }
        }
        
        //  Encode the images array
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(images) {
            //  .... and save the images array to UserDefaults
            UserDefaults.standard.set(encoded, forKey: "images")
        }
        
        //  .....then reload the tableView to reflect the change.
        tableView.reloadData()
    }
    
    func generateThumbnailImage(item: String) -> String {
        
        //  Use the curernt image to grab the Thumb version 750 x 750
        let currentImage = item
        let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
        //  Build the path
        let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
        //  Use the path as the contents to populate the UIImage.
        let original = UIImage(contentsOfFile: path)!       // Force unwrapped because we know that it exists
        
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)
        
        //  Just resize the image.  Rendering into an Ellipse still needs to be done in cellForRowAt
        let resized = renderer.image { ctx in
            original.draw(in: renderRect)
        }
        
        // Write image to User documents folder
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        //  Write the JPEG DATA file to the App Documents folder.
        if let jpegData = resized.jpegData(compressionQuality: 0.8) {
            do {
                try jpegData.write(to: imagePath)
            } catch {
                fatalError("Failed to write image to file \(error.localizedDescription)")
            }
        }
        //  Return an image name (UUID) which is the unique identifier to the file containing the image Data
        return imageName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dirty {
            // we've been marked as needing a counter reload, so reload the whole table
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return images.count * 10
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //  Get the image file name from the images array
        let imageName = images[indexPath.row % images.count].imageName
        //  Build the URL using appendingPathComponent
        let imageURL = getDocumentsDirectory().appendingPathComponent(imageName)
        //  Get the image data
        let data = try? Data(contentsOf: imageURL)
        //  and convert into a format that can be displayed in a UIImage
        let imageFromFile = UIImage(data: data!)
        
        //  Define a rectangle to render into
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        //  Setup the renderer
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)
        
        let rounded = renderer.image { ctx in
            ctx.cgContext.addEllipse(in: renderRect)
            ctx.cgContext.clip()
            
            //  Draw the image into the renderer
            imageFromFile!.draw(in: renderRect)
        }
        //  ..... and assign the rendered image to the cell imageView.
        cell.imageView!.image = rounded
        
        // give the images a nice shadow to make them look a bit more dramatic
        cell.imageView?.layer.shadowColor = UIColor.black.cgColor
        cell.imageView?.layer.shadowOpacity = 1
        cell.imageView?.layer.shadowRadius = 10
        cell.imageView?.layer.shadowOffset = CGSize.zero
        
        //  Draw an oval around the circumference of the image which defines the shadow path
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath
        
        // each image stores how often it's been tapped which is saved ot UserDefaults
        let defaults = UserDefaults.standard
        cell.textLabel?.text = "\(defaults.integer(forKey: images[indexPath.row % images.count].filename))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ImageViewController()
        vc.image = images[indexPath.row % images.count].filename
        vc.owner = self
        
        // mark us as not needing a counter reload when we return
        dirty = false
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //  Returns the App Document path (URL)
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
