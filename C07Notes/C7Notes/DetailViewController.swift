//
//  NoteViewController.swift
//  C7Notes
//
//  Created by Chris Parker on 12/5/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var noteTextView: UITextView!
    
    var notes: [Note] = []
    var selectedNote: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // This is called when the Back button is tapped, and makes sure that the current data is saved
        save()
    }
    
    func configureUI() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        
        noteTextView.delegate = self
        noteTextView.font = UIFont(name: "Helvetica Neue", size: 18)
        
        if selectedNote == nil {
            noteTextView.text = ""
            noteTextView.becomeFirstResponder()
        } else {
            noteTextView.text = notes[selectedNote].text
        }

    }
    
    func configureNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            noteTextView.contentInset = .zero
        } else {
            noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        noteTextView.scrollIndicatorInsets = noteTextView.contentInset
        
        let selectedRange = noteTextView.selectedRange
        noteTextView.scrollRangeToVisible(selectedRange)
    }
    
    @objc func done() {
        noteTextView.resignFirstResponder()
    }
    
    func save() {
        
        if selectedNote != nil {
            if notes[selectedNote].text != noteTextView.text {
                //  A change has been made so Save selected note to notes array.
                notes[selectedNote].text = noteTextView.text
                notes[selectedNote].date = Date()
            }
            
        } else {
            
            if noteTextView.text != "" {
                //  Append new note
                let newNote = Note(text: noteTextView.text, date: Date())
                notes.append(newNote)
                selectedNote = notes.count - 1
            }
        }
        
        //  Encode and Save edited data to UserDefaults
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.notes) {
            //  .... and save the notes array to UserDefaults
            UserDefaults.standard.set(encoded, forKey: "notes")
        }
        
        //  pass back updated notes array
        let vc = NotesTableViewController()
        vc.notes = notes
    
    }

}
