//
//  FlagListViewController.swift
//  C1WorldFlags
//
//  Created by Chris Parker on 2/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class FlagListViewController: UITableViewController {

    var flags = [String]()
    
    @IBOutlet var flagsImageView: UIImageView!
    @IBOutlet var flagsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Flag Viewer"
        let barImage = UIImage(named: "white")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(barImage, for: .default)
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasSuffix("png") &&  item.contains("@3x") {
                // this is a picture to load!
                let splitItem = item.split(separator: "@")
//                let index = item.firstIndex(of: "@") ?? item.endIndex
//                let newItem = item[..<index]
//                flags.append(String(newItem))
                flags.append(String(splitItem[0]))
                flags = flags.sorted()
            }
        }
        
        // Hides separator lines on unused cells
        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        if flags[indexPath.row].count <= 2 {
            cell.textLabel?.text = flags[indexPath.row].capitaliseFirstLetter()
        } else {
            cell.textLabel?.text = flags[indexPath.row].capitaliseFirstLetter()
        }        
        cell.imageView?.image = UIImage(named: flags[indexPath.row])
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
        cell.imageView?.layer.cornerRadius = 5
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = flags[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}


