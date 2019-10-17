//
//  ActionViewController.swift
//  Extension
//
//  Created by Chris Parker on 28/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    
    var scripts = [Script]()
    
    var scriptName = [String]()
    var scriptURL = [String]()
    var scriptContent = [String]()
    
    var scriptIndex = 0
    var scriptIndexSelected = false
    var returnFromTableView = false
    var scriptsTableViewAccessed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Navigation toolbar setup
        //  Right bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveScript))
        //  Left bar button item.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectScript))
        
        //  Read UserDefaults and scripts array with saved userDefaults data
        if let savedScripts = UserDefaults.standard.object(forKey: "scripts") as? Data {
            let decoder = JSONDecoder()
            if let loadedScripts = try? decoder.decode([Script].self, from: savedScripts){
                self.scripts = loadedScripts
            }
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    //  The following code is a closure within a closure, therefore there is no need to include '[weak self] in'
                    //  because 'self' is already weak in the outer closure.
                    DispatchQueue.main.async {  // [weak self] in
                        if let title = self?.pageTitle {
                            var count = 0
                            if title.count > 18 {
                                count = title.count - 1
                            } else {
                                count = title.count - 1
                            }
                            let characters = Array(title)
                            var charArray = [Character]()
                            for index in 0...count {
                                charArray = charArray + [characters[index]]
                            }
                            let newTitle = String(charArray)
                            self?.title = newTitle
                        }
                        
                    }
                }
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//  TODO: Maybe this is the means to deal with returning from the ScriptsTableViewController
        if scriptIndexSelected == true && returnFromTableView == true {
            script.text =  scripts[scriptIndex].scriptContent
            print(script.text!)
        } else if scriptIndexSelected == false && scriptsTableViewAccessed == true {
            sampleScripts()
        }
    }
    
    @IBAction func done() {
        let item = NSExtensionItem()
        print(script.text!)
        let argument: NSDictionary = ["customJavaScript": script.text!]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }    
    
    @objc func selectScript() {
        
        //  Instantiate ScriptsTableViewController and pass the scripts array
        //  to it for display in the tableView.
        
        scriptsTableViewAccessed = true
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ScriptTable") as? ScriptsTableViewController {
            vc.scripts = scripts
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc func sampleScripts() {
        
        scriptsTableViewAccessed = false
        
        //  Sample scripts to run if no script selected from tableView
        let alert = UIAlertController(title: "Sample Scripts", message: "Choose a Script", preferredStyle: .alert)
        //  First script
        let showTitleAction = UIAlertAction(title: "Show Title", style: .default) { (action) in
            self.script.text = "alert(document.title);"
        }
        //  Second script
        let showDateAction = UIAlertAction(title: "Show URL", style: .default) { (action) in
            self.script.text = "alert(document.URL);"
        }
        //  Third script
        let showLastModifiedAction = UIAlertAction(title: "Show date last modified", style: .default) { (action) in
            self.script.text = "alert(document.lastModified);"
        }
        //  Fourth script
        //document.body.style.backgroundColor = "red"
        let changeColorAction = UIAlertAction(title: "Set background to red", style: .default) { (action) in
            self.script.text = "document.body.style.backgroundColor = \"red\";"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(showTitleAction)
        alert.addAction(showDateAction)
        alert.addAction(showLastModifiedAction)
        alert.addAction(changeColorAction)
        
        //  Read UserDefaults and Create Actions from saved scripts
        if let savedScripts = UserDefaults.standard.object(forKey: "scripts") as? Data {
            let decoder = JSONDecoder()
            if let loadedScripts = try? decoder.decode([Script].self, from: savedScripts){
                self.scripts = loadedScripts
            }
        }
        print(scripts)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc func saveScript() {
        let ac = UIAlertController(title: "Save Script", message: "Give the script a name.", preferredStyle: .alert)
        ac.addTextField()
        let runAction = UIAlertAction(title: "Just run", style: .default) { action in
            self.done()
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak ac] action in
            guard let self = self else { return }
            guard let textString = ac?.textFields?[0].text else { return }
            let newScript = Script(scriptName: textString, scriptURL: self.pageURL, scriptContent: self.script.text)
            //  Append the new entry to scripts array .....
            self.scripts.append(newScript)
            //  .... Encode....
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.scripts) {
                //  .... and save the scripts array to UserDefaults
                UserDefaults.standard.set(encoded, forKey: "scripts")
            }
            self.done()
        }
        
        ac.addAction(runAction)
        ac.addAction(saveAction)
        
        self.present(ac, animated: true)
        
    }

}
