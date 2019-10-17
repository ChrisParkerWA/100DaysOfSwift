//
//  ViewController.swift
//  P10AStormViewer
//
//  Created by Chris Parker on 25/2/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        //  Challenge Q1 Project 9 - (Day 40) to use the 'background' thread to load the image file names.
        performSelector(inBackground: #selector(loadImageNames), with: nil)
        
    }
    
    //  Challenge Q1 Project 9 - (Day 40) to use the 'background' thread to load the image file names.
    @objc func loadImageNames() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                // this is a picture to load!
                pictures.append(item)
                pictures = pictures.sorted()
                
                //  Challenge Q1 Project 9 - (Day 40)  to use the main thread to reload the tableView
                self.collectionView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: false)
            }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? PictureCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        cell.imageView.image = UIImage(named: pictures[indexPath.row])
        cell.fileName.text = pictures[indexPath.row]
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.imageView.clipsToBounds = true
        cell.layer.cornerRadius = 7
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.totalPictures = pictures.count
            vc.selectImageNumber = indexPath.row + 1
            navigationController?.pushViewController(vc, animated: true)
        }
    }    
    
    @objc func shareTapped() {
        let message = "Have a look at this App named Storm Viewer"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}

