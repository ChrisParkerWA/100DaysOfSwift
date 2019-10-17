//
//  NotesTableViewController.swift
//  C7Notes
//
//  Created by Chris Parker on 12/5/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {
    
    var notes: [Note] = []
    var noteCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        //  Load notes array from UserDefaults.
        if let savedNotes = UserDefaults.standard.object(forKey: "notes") as? Data {
            let decoder = JSONDecoder()
            if let loadedNotes = try? decoder.decode([Note].self, from: savedNotes){
                self.notes = loadedNotes
            }
        }
        
        tableView.reloadData()
        updateNoteCountLabel()
    }
    
    func configureUI() {
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .orange
        navigationController?.toolbar.tintColor = .orange
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
        navigationController?.toolbar.shadowImage(forToolbarPosition: .bottom)
        navigationController?.toolbar.isTranslucent = true
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editNotes))
        
        noteCountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 21))
        noteCountLabel.font = UIFont.systemFont(ofSize: 11)
        noteCountLabel.textColor = UIColor.black
        noteCountLabel.center = CGPoint(x: view.frame.midX, y: view.frame.height)
        noteCountLabel.textAlignment = .center
        
        let toolBarText = UIBarButtonItem(customView: noteCountLabel)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let compose = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeNote))
        
        toolbarItems = [spacer, toolBarText, spacer, compose]
        navigationController?.isToolbarHidden = false
        
        let backgroundImage = UIImage(named: "background2")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = backgroundImageView
        
        // Hides separator lines on unused cells
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
    }
    
    func updateNoteCountLabel() {
        noteCountLabel.text = "\(notes.count) Notes"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        let note = notes[indexPath.row]
        //  Only the first line or first 30 characters of the note text
        cell.textLabel!.text = note.title()
        cell.textLabel!.font = UIFont(name: "Helvetica Neue", size: 16)
        //  The date is to prefix the field and the next line or next 40 characters to be appended
        cell.detailTextLabel!.text = note.dateString() + " - " + note.subTitle()
        cell.detailTextLabel!.font = UIFont(name: "Helvetica Neue", size: 14)
        
        cell.detailTextLabel?.alpha = 0.5
        cell.backgroundColor = UIColor.clear
        
        let backgroundImage = UIImage(named: "background2")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        cell.backgroundView = backgroundImageView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController {
            vc.selectedNote = indexPath.row
            vc.notes = notes
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            self.notes.remove(at: indexPath.row)
            
            //  Save notes array to UserDefaults......
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.notes) {
                //  .... and save the notes array to UserDefaults
                UserDefaults.standard.set(encoded, forKey: "notes")
            }
            
            //  .....then reload the tableView to reflect the change.
            tableView.reloadData()
            self.updateNoteCountLabel()
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        deleteAction.image = #imageLiteral(resourceName: "trash2_30")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    @objc func editNotes() {
        
    }
    
    @objc func composeNote() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController {
            vc.selectedNote = nil
            vc.notes = notes
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
