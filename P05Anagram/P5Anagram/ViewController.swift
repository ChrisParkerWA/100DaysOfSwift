//
//  ViewController.swift
//  P5Anagram
//
//  Created by Chris Parker on 3/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    var selectedWord: String?
    /*
     originalWord has been defined to store the word at the time it was selected (selectedWord).
     I have introduced a method to shuffle the word (selectedWord) during gameplay and when
     a test is made to disallow the user to enter a word the same as the original word, we need
     to refer back to the original word given that selectedWord is now shuffled.
    */
    var originalWord: String?
    var customWord: String?
    var isSortedAscending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Setup for animating the logo prior to the tableview appearing.
        tableView.alpha = 0
//        let degrees = Double(360)
//        let radians = CGFloat(degrees * Double.pi / 180)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.tableView.alpha = 1
        })
        
        let barImage = UIImage(named: "white")
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(barImage, for: .default)
        
        navigationController?.toolbar.isTranslucent = true
        navigationController?.toolbar.setBackgroundImage(barImage, forToolbarPosition: .bottom, barMetrics: .default)
        
        //  MARK: Question 3 of the challenge.  Add nav button item to start the game at any time.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startGame))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let sortAscending = UIBarButtonItem(image: UIImage(named: "sortAscending"), style: .done, target: self, action: #selector(sortListAscending))
        let sortDescending = UIBarButtonItem(image: UIImage(named: "sortDescending"), style: .done, target: self, action: #selector(sortListDescending))
        let random = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(randomizeLetters))
        let custom = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(customGame))
        
        toolbarItems = [sortDescending, spacer, sortAscending, spacer, random, spacer, custom, spacer, share]
        navigationController?.isToolbarHidden = false
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        let itemsObject = UserDefaults.standard.object(forKey: "usedWords")
        
        if let tempItems = itemsObject as? [String] {
            usedWords = tempItems
        }
        
        selectedWord = UserDefaults.standard.object(forKey: "selectedWord") as? String
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        !usedWords.isEmpty ? resumeGame() : startGame()
        
        // Hides separator lines on unused cells
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        
        //  Shade the cell w.r.t the background.
        cell.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            self.usedWords.remove(at: indexPath.row)
            UserDefaults.standard.set(self.usedWords, forKey: "usedWords")
            tableView.reloadData()
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        deleteAction.image = #imageLiteral(resourceName: "trash2_30")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    // MARK: Game Control
    func resumeGame() {
        title = "\(String(describing: selectedWord!)) - Score: \(usedWords.count)"
        originalWord = selectedWord
        tableView.reloadData()
    }
    
    @objc func startGame() {
        selectedWord = allWords.randomElement()
        originalWord = selectedWord
        UserDefaults.standard.set(selectedWord, forKey: "selectedWord")
        title = "\(String(describing: selectedWord!)) - Score: \(usedWords.count)"
        usedWords.removeAll(keepingCapacity: true)
        saveUserDefaults(andRefreshTable: true)
    }
    
    @objc func customGame() {
        //  Show alert requesting word from user
        let ac = UIAlertController(title: "Enter word of 8 or more characters", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.autocorrectionType = .default
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let self = self else { return }
            guard let wordEntered = ac?.textFields?[0].text else { return }
            if wordEntered.count == 0 {
                self.showErrorMessage(withTitle: "Nothing Entered", andMessage: "Enter a word greater than 2 letters.")
                return
            } else if wordEntered.count < 8 {
                self.showErrorMessage(withTitle: "Word is too short!", andMessage: "Your word must be 8 letters or longer")
                return
            }
            self.startCustomGame(wordEntered)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func startCustomGame(_ customWord: String) {
        selectedWord = customWord.lowercased()
        originalWord = selectedWord
        UserDefaults.standard.set(selectedWord, forKey: "selectedWord")
        usedWords.removeAll(keepingCapacity: true)
        title = "\(String(describing: selectedWord!)) - Score: \(usedWords.count)"
        saveUserDefaults(andRefreshTable: true)
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let self = self else { return }
            guard let answer = ac?.textFields?[0].text else { return }
            if answer.count == 0 {
                self.showErrorMessage(withTitle: "Nothing Entered", andMessage: "Enter a word greater than 2 letters.")
                return
            }
            let trimmedAnswer = answer.trimmingCharacters(in: .whitespaces)
            self.submit(trimmedAnswer.lowercased())
            //  MARK: This was the subtle bug that @twostraws was talking about in the Challenge question.  The solution was to change the answer to lowercase.  I removed any leading and trailing whitespaces.
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer

        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer.lowercased(), at: 0)
                    saveUserDefaults(andRefreshTable: false)

                    title = "\(String(describing: selectedWord!)) - Score: \(usedWords.count)"
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    showErrorMessage(withTitle: "Word '\(answer)' not recognised", andMessage: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage(withTitle: "Word '\(answer)' already used", andMessage: "Be more original!")
            }
        } else {
            showErrorMessage(withTitle: "Word '\(answer)' is not possible", andMessage: "You can't spell that word \nfrom \(title!.lowercased())")
        }
    }
    
    func showErrorMessage(withTitle errorTitle: String, andMessage errorMessage: String) {
        //  MARK:  Question 2 - refactor the alert Controller code.
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = originalWord?.lowercased() else { return false }

//        print("New Word entered.")
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
//                print("letter: '\(letter)', tempWord: '\(tempWord)'")
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        //  MARK: Question 1 of the challenge - respond if the answer is shorter than 3 letters OR if tha answer is the same as the selected word.
        if word.utf16.count < 3 {
            showErrorMessage(withTitle: "Word is too short!", andMessage: "Your word must be 3 letters or longer.")
            return false
        } else if word == originalWord?.lowercased() {
            showErrorMessage(withTitle: "Answer is the same as the original selected word '\(originalWord!)'!", andMessage: "Try choosing a different Anagram.")
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    fileprivate func saveUserDefaults(andRefreshTable refresh: Bool) {
        UserDefaults.standard.set( usedWords, forKey: "usedWords")
        if refresh {
            tableView.reloadData()
        }
    }
    //  MARK: TabBarOptions
    @objc func sortListAscending() {
        usedWords = usedWords.sorted()
        isSortedAscending = true
        saveUserDefaults(andRefreshTable: true)
    }
    
    @objc func sortListDescending() {
        // Test that the list is sorted in ascending order before reversing the list.
        if isSortedAscending {
            usedWords = usedWords.reversed()
            isSortedAscending = false
            saveUserDefaults(andRefreshTable: true)
        }
        
    }
    
    @objc func randomizeLetters() {
        var letters = Array(selectedWord!)
        letters.shuffle()
        let shuffledLetters = String(letters)
        selectedWord = shuffledLetters
        title = "\(String(describing: selectedWord!)) - Score: \(usedWords.count)"
    }
    
    @objc func shareTapped() {
        var message = "\(usedWords.count) Anagrams from the word \(String(describing: selectedWord!)): "
        message += usedWords.joined(separator: ", ")
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
