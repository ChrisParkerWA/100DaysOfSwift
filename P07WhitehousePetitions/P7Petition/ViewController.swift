//
//  ViewController.swift
//  P7Petition
//
//  Created by Chris Parker on 6/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    var filterText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredit))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(setFilter))
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            //  "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
            title = "Petitions"
        } else {
            //  "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
            title = "Top Rated Petitions"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                //  We're OK to parse
                parse(json: data)
                filteredPetitions = petitions
                return
            }
        }
        showError()
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    
    }
    
    fileprivate func displayAlert(_ title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showCredit() {
        displayAlert("Data from We The People API of the Whitehouse", message: "")
    }
    
    func showError() {
        displayAlert("Loading error", message: "There was a problem loading the feed; please check your connection and try again.")
    }
    
    @objc func setFilter() {
        let ac = UIAlertController(title: "Set Search Filter", message: "Enter your search string", preferredStyle: .alert)
        ac.addTextField()
    
        let filterAction = UIAlertAction(title: "Filter", style: .default) { [weak self, weak ac] action in
            guard let self = self else { return }
            guard let textString = ac?.textFields?[0].text else { return }
            self.filterText = textString.lowercased()
            if self.filterText != "" {
                self.filterPetitions(self.filterText!)
            }
        }
        
        let clearAction = UIAlertAction(title: "Clear Search", style: .default) { ( action ) in
            self.filteredPetitions = self.petitions
            self.tableView.reloadData()
        }
        
        ac.addAction(filterAction)
        ac.addAction(clearAction)
        present(ac, animated: true)
    }
    
    func filterPetitions(_ filterText: String) {
        filteredPetitions = petitions.filter({ ($0.title).lowercased().contains(filterText) || ($0.body).lowercased().contains(filterText)})
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

