//
//  WebsiteListViewController.swift
//  P4ABrowser

//
//  Created by Chris Parker on 3/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class WebsiteListViewController: UITableViewController {

    var websites = ["apple.com", "twitter.com", "hackingwithswift.com", "google.com"]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Websites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Websites", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedWebsite = websites[indexPath.row]
            vc.websites = websites
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
