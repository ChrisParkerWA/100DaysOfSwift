//
//  ScriptsTableViewController.swift
//  Extension
//
//  Created by Chris Parker on 30/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ScriptsTableViewController: UITableViewController {
    
    var scripts = [Script]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Scripts"
        
        if let savedScripts = UserDefaults.standard.object(forKey: "scripts") as? Data {
            let decoder = JSONDecoder()
            if let loadedScripts = try? decoder.decode([Script].self, from: savedScripts){
                self.scripts = loadedScripts
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scripts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = scripts[indexPath.row].scriptName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ActionVC") as? ActionViewController {
            vc.scripts = scripts
            vc.scriptIndex = indexPath.row
            vc.scriptIndexSelected = true
            vc.returnFromTableView = true
            navigationController?.pushViewController(vc, animated: true)
        }
        
//        exitTableView()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            self.scripts.remove(at: indexPath.row)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.scripts) {
                //  .... and save the scripts array to UserDefaults
                UserDefaults.standard.set(encoded, forKey: "scripts")
            }
            tableView.reloadData()
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        deleteAction.image = #imageLiteral(resourceName: "trash2_30")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    func exitTableView() {
        print("self.dismiss called")
        self.dismiss(animated: true)
    }
    
}
