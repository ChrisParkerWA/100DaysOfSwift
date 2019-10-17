//
//  ViewController.swift
//  P1StormViewer
//
//  Created by Chris Parker on 25/2/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    var viewCount: [Int] = []
    
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
                self.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            }
        }
        
        let itemsObject = UserDefaults.standard.object(forKey: "viewCount")
        
        if let tempItems = itemsObject as? [Int] {
            
            viewCount = tempItems
            
        } else {
            let startValue = 0
            for _ in 0...pictures.count - 1 {
                viewCount.append(startValue)
            }
            print(viewCount)
            UserDefaults.standard.set(viewCount, forKey: "viewCount")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 25)
        cell.detailTextLabel?.text = "View Count: \(viewCount[indexPath.row])"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.totalPictures = pictures.count
            vc.selectImageNumber = indexPath.row + 1
            navigationController?.pushViewController(vc, animated: true)
        }
        viewCount[indexPath.row] += 1
        UserDefaults.standard.set(viewCount, forKey: "viewCount")
        tableView.reloadData()
    }
    
    @objc func shareTapped() {
        let message = "Have a look at this App named Storm Viewer"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}

