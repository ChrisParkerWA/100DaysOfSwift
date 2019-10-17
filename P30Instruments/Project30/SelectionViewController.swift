//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
    var images = [UIImage]()    //  This array store the images generated from the filenames

	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"
        navigationController?.navigationBar.prefersLargeTitles = true

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		// load all the JPEGs into our array
		let fm = FileManager.default
        
        //  Get a list of all the files in the App Bundle.
		if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
            //  If Files are found in the App folder then loop through the list
			for item in tempItems {
                //  For each file in the folder, if the filename contains 'Large' then
				if item.range(of: "Large") != nil {
                    //  append that item to the array
					items.append(item)
				}
			}
		}
        generateThumnails()
    }
    
    func generateThumnails() {
        
        for index in 0...items.count - 1 {
            let currentImage = items[index]
            let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
            let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
            let original = UIImage(contentsOfFile: path)!
            
            let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
            let renderer = UIGraphicsImageRenderer(size: renderRect.size)
            
            let rounded = renderer.image { ctx in
                ctx.cgContext.addEllipse(in: renderRect)
                ctx.cgContext.clip()
                
                original.draw(in: renderRect)
            }
            // Write image to User documents
//            let imageName = UUID().uuidString
//            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
//
//            if let jpegData = rounded.jpegData(compressionQuality: 0.8) {
//                try? jpegData.write(to: imagePath)
//            } else {
//                fatalError("Failed to write image to file")
//            }
            
            images.append(rounded)
        }
        
        // Save the cache of image to the file system.
    }
    
    func writeFile(image: UIImage) {
        
        
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
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		// find the image for this cell, and load its thumbnail
        let currentImage = items[indexPath.row % items.count]
//        let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
//        let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
//        let original = UIImage(contentsOfFile: path)!
//
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
//        let renderer = UIGraphicsImageRenderer(size: renderRect.size)
//
//        let rounded = renderer.image { ctx in
//            ctx.cgContext.addEllipse(in: renderRect)
//            ctx.cgContext.clip()
//
//            original.draw(in: renderRect)
//        }

		cell.imageView?.image = images[indexPath.row % items.count]

		// give the images a nice shadow to make them look a bit more dramatic
        cell.imageView?.layer.shadowColor = UIColor.black.cgColor
        cell.imageView?.layer.shadowOpacity = 1
        cell.imageView?.layer.shadowRadius = 7
        cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false
        
		navigationController?.pushViewController(vc, animated: true)
	}
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
