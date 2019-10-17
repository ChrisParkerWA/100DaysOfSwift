//
//  ViewController.swift
//  C3Hangman
//
//  Created by Chris Parker on 14/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import CoreMotion

class HangmanViewController: UIViewController {
    
    var clueLabel: UILabel!
    var answerLabel: UILabel!
    var guessesLabel: UILabel!
    var usedLettersLabel: UILabel!
    var letterButtons = [UIButton]()
    var buttonsView: UIView!
    var gallowsImageView: UIImageView!
    var manImageView: UIImageView!
    var gallowsStackView: UIStackView!
    var clueAnswerStack: UIStackView!
    var gameStack: UIStackView!
    
    var allWords = [String]()
    var selectedWord: String?
    var customWord: String = ""
    var sourceFile: String = "hangman"
    var usedLetters = [String]()
    var selectedLetter: Character?
    var activatedButtons = [UIButton]() //  Stores buttons that have been pressed.
//    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let alphabet = "1234567890QWERTYUIOPASDFGHJKL'ZXCVBNM,.:"
    var wrongAnswers = 0 {
        didSet {
            manImageView.image = UIImage(named: "man\(wrongAnswers)")
        }
    }
    var guessesRemaining = 0 {
        didSet {
            guessesLabel.text = "You have \(guessesRemaining) \(guessesRemaining == 1 ? "guess" : "guesses") remaining."
        }
    }
    
    override func loadView() {
        
        //  Set up UI in code
        
        view = UIView()
        view.backgroundColor = .white
        
        manImageView = UIImageView()
        manImageView.translatesAutoresizingMaskIntoConstraints = false
        manImageView.image = UIImage(named: "man7")
        manImageView.contentMode = UIView.ContentMode.scaleToFill
        view.addSubview(manImageView)
        
        gallowsImageView = UIImageView()
        gallowsImageView.translatesAutoresizingMaskIntoConstraints = false
        gallowsImageView.image = UIImage(named: "gallows")
        gallowsImageView.contentMode = UIView.ContentMode.scaleToFill
        gallowsImageView.layer.borderColor = UIColor.lightGray.cgColor
        gallowsImageView.layer.borderWidth = 1
        gallowsImageView.backgroundColor = nil
        view.addSubview(gallowsImageView)
        
        usedLettersLabel = UILabel()
        usedLettersLabel.translatesAutoresizingMaskIntoConstraints = false
        usedLettersLabel.textAlignment = .center
        usedLettersLabel.font = UIFont.systemFont(ofSize: 17)
        view.addSubview(usedLettersLabel)
        
        
        clueLabel = UILabel()
        clueLabel.translatesAutoresizingMaskIntoConstraints = false
        clueLabel.textAlignment = .center
        clueLabel.font = UIFont.systemFont(ofSize: 17)
        view.addSubview(clueLabel)
        
        guessesLabel = UILabel()
        guessesLabel.translatesAutoresizingMaskIntoConstraints = false
        guessesLabel.textAlignment = .center
        guessesLabel.font = UIFont.systemFont(ofSize: 17)
        view.addSubview(guessesLabel)
        
        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.textAlignment = .center
        answerLabel.font = UIFont.systemFont(ofSize: 20)
        answerLabel.text = "_ _ _ _ _ _ _"
        answerLabel.isUserInteractionEnabled = false
        view.addSubview(answerLabel)
        
        buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
//        gallowsStackView = UIStackView(arrangedSubviews: [gallowsImageView, manImageView])
//        gallowsStackView.translatesAutoresizingMaskIntoConstraints = false
//        gallowsStackView.axis = .horizontal
//        gallowsStackView.distribution = .equalCentering
//        gallowsStackView.alignment = .center
//        view.addSubview(gallowsStackView)
        
        NSLayoutConstraint.activate([

//            gallowsStackView.widthAnchor.constraint(equalToConstant: 150),
//            gallowsStackView.heightAnchor.constraint(equalToConstant: 155),
//            gallowsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            gallowsStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 70),
            
            gallowsImageView.widthAnchor.constraint(equalToConstant: 150),
            gallowsImageView.heightAnchor.constraint(equalToConstant: 150),
            gallowsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gallowsImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 70),
            
            manImageView.widthAnchor.constraint(equalToConstant: 100),
            manImageView.heightAnchor.constraint(equalToConstant: 100),
            manImageView.centerXAnchor.constraint(equalTo: gallowsImageView.centerXAnchor),
            manImageView.topAnchor.constraint(equalTo: gallowsImageView.topAnchor, constant: -5),
//            manImageView.bottomAnchor.constraint(equalTo: gallowsImageView.bottomAnchor, constant: -50),
            
            guessesLabel.centerXAnchor.constraint(equalTo: clueLabel.centerXAnchor),
            guessesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            guessesLabel.bottomAnchor.constraint(equalTo: clueLabel.topAnchor, constant: -7),
            
            clueLabel.centerXAnchor.constraint(equalTo: usedLettersLabel.centerXAnchor),
            clueLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            clueLabel.bottomAnchor.constraint(equalTo: usedLettersLabel.topAnchor, constant: -7),
            
            usedLettersLabel.centerXAnchor.constraint(equalTo: answerLabel.centerXAnchor),
            usedLettersLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            usedLettersLabel.bottomAnchor.constraint(equalTo: answerLabel.topAnchor, constant: -7),
            
            answerLabel.centerXAnchor.constraint(equalTo: buttonsView.centerXAnchor),
            answerLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            answerLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -7),
 
            buttonsView.widthAnchor.constraint(equalToConstant: 370),
            buttonsView.heightAnchor.constraint(equalToConstant: 148),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)

            ])
        
        // set some values for the width and height of each button
        let width = 37
        let height = 37
        
        // create 40 buttons as a 10x4 grid
        var row = 0
        var col = 0
     
        for letter in alphabet {
            var frame = CGRect()
            // create a new button and give it a big font size
            let letterButton = UIButton(type: .system)
            letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            
            // give the button some temporary text so we can see it on-screen
            letterButton.setTitle("\(letter)", for: .normal)
            letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
            
            // calculate the frame of this button using its column and row
            if letter == " " {
                frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                letterButton.isHidden = true
            } else {
                frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.lightGray.cgColor
                letterButton.layer.cornerRadius = letterButton.frame.height / 4
            }
            
            // add it to the buttons view
            buttonsView.addSubview(letterButton)
            
            // and also to our letterButtons array
            letterButtons.append(letterButton)
            
            //  7 columns wide by 4 rows deep.
            if col < 9 {
                col += 1
            } else {
                row += 1
                col = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playTapped(_:)))
        let fileButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(selectFile))
        navigationItem.leftBarButtonItems = [playButton, fileButton]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(customGameTapped(_:)))
        
        loadWords()
        selectWord()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            // Deactivate constraints and activate new constraints to suit Landscape
            
        } else {
            print("Portrait")
            // Deactivate constraints and activate new constraints to suit Portrait
       
        }
    }
    
    func loadWords() {
        if let startWordsURL = Bundle.main.url(forResource: sourceFile, withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
    }

    func selectWord() {
        if customWord != "" {
            selectedWord = customWord.uppercased()
            title = "HANGMAN - Custom"
        } else {
            selectedWord = allWords.randomElement()?.uppercased()
            if sourceFile == "hangman" {
                title = "HANGMAN - General"
            } else if sourceFile == "movies" {
                title = "HANGMAN - Movies"
            }
        }
        
        clueLabel.text = "Word to solve has \(selectedWord!.replacingOccurrences(of: " ", with: "").count) letters."
        usedLetters.removeAll()
        usedLettersLabel.text = "Letters used: ()"
        guessesRemaining = 7
        wrongAnswers = 0
        
        
        var answerString = ""
        let tempWord = Array(selectedWord!)
        
        for index in 0...selectedWord!.count - 1 {
            if tempWord[index] == " " {
                answerString += " "
            } else {
                answerString += "?"
            }
        }

        answerLabel.text = answerString
//        print(selectedWord!)
//        print("'\(answerString)'")
        
        setButtonStatus(true)
    }
    
    @objc func playTapped(_ sender: UIButton) {
        customWord = ""
        selectWord()
        for sender in activatedButtons {
            sender.isHidden = false
        }
    }
    
    @objc func selectFile() {
        let ac = UIAlertController(title: "Choose source file.", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Random Words", style: .default, handler: chooseFile))
        ac.addAction(UIAlertAction(title: "Movie Titles", style: .default, handler: chooseFile))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func chooseFile( action: UIAlertAction) {
        // safely read the alert action's title
        guard let actionTitle = action.title else { return }
        if actionTitle == "Random Words" {
            sourceFile = "hangman"
        } else if actionTitle == "Movie Titles" {
            sourceFile = "movies"
        }
        loadWords()
        selectWord()
        for sender in activatedButtons {
            sender.isHidden = false
        }
    }
    
    @objc func customGameTapped(_ sender: UIButton) {
        for sender in activatedButtons {
            sender.isHidden = false
        }
        let ac = UIAlertController(title: "Enter word (or a phrase) of 3 or more characters.  Maximum number of 31 characers including spaces.", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.autocorrectionType = .default
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let self = self else { return }
            guard let wordEntered = ac?.textFields?[0].text else { return }
            if wordEntered.count == 0 {
                self.showAlert("Nothing Entered", message: "Enter a word (or a phrase) greater than 3 letters. Maximum of 31 characters incuding spaces.", buttonText: "OK")
                return
            } else if wordEntered.count < 4 {
                self.showAlert("Word is too short!", message: "Your word or phrase must be 4 letters or longer. Maximum of 31 characters incuding spaces.", buttonText: "OK")
                return
            } else if wordEntered.count > 31 {
                self.showAlert("Word is too long!", message: "Your word or phrase must be a maximum of 31 characters incuding spaces.", buttonText: "OK")
                return
            }
            self.customWord = wordEntered
            self.selectWord()
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        selectedLetter = Character(buttonTitle)
        usedLetters.append("\(selectedLetter!)")
        usedLettersLabel.text = "Letters used: (\(usedLetters.joined(separator: ",")))"
        activatedButtons.append(sender)
        sender.isHidden = true
        isLetterInWord()
    }
    
    func isLetterInWord() {
        if selectedWord!.contains(selectedLetter!) == true {
            updateAnswerMask()
            isGameOver()
        } else {
            guessesRemaining -= 1
            wrongAnswers += 1
            isGameOver()
        }
    }
    
    func updateAnswerMask() {
        var answerArray = Array(answerLabel.text!)
        var selectedWordArray = Array(selectedWord!)
        for index in 0..<selectedWordArray.count {
            if selectedWordArray[index] == selectedLetter {
                answerArray[index] = selectedLetter!
            }
        }
        answerLabel.text = String(answerArray)
    }
    
    func isGameOver() {
        let answerText = answerLabel.text
        if selectedWord == answerText {
            
            setButtonStatus(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
                self.showAlert("Congratulations", message: "You solved the word/phrase\n'\(self.selectedWord!)'\nwith \(self.guessesRemaining) \(self.guessesRemaining == 1 ? "guess" : "guesses") remaining.\nPress the ▶︎ button to play again", buttonText: "OK")
            })
            
        } else if guessesRemaining == 0 {
            animateVictim()
            showAlert("Game Over", message: "You have \(guessesRemaining) guesses remaining.\nThe word or phrase was\n'\(selectedWord!)'\nPress the ▶︎ button to play again or click compose to choose your own word or phrase.", buttonText: "OK")
            print(selectedWord!)
            setButtonStatus(false)            
        }
        
    }
    
    func animateVictim() {
        let degrees = Double(30)
        let radians = CGFloat(degrees * Double.pi / 180)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: radians)
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: 0)
        })
        UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: -radians)
        })
        UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseIn, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: 0)
        })
        UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseOut, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: radians)
        })
        UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseIn, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: 0)
        })
        UIView.animate(withDuration: 0.5, delay: 3, options: .curveEaseOut, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: -radians)
        })
        UIView.animate(withDuration: 0.5, delay: 3.5, options: .curveEaseIn, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: 0)
        })
        UIView.animate(withDuration: 0.5, delay: 4, options: .curveEaseOut, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: radians)
        })
        UIView.animate(withDuration: 0.5, delay: 4.5, options: .curveEaseIn, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: 0)
        })
        UIView.animate(withDuration: 0.5, delay: 5, options: .curveEaseOut, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: -radians)
        })
        UIView.animate(withDuration: 0.5, delay: 5.5, options: .curveEaseInOut, animations: {
            self.manImageView.transform = CGAffineTransform(rotationAngle: 0)
        })
        
    }
    
    func setButtonStatus(_ status: Bool) {
        for button in letterButtons {
            button.isEnabled = status
        }
    }
    
    func showAlert(_ title: String, message: String, buttonText: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: buttonText, style: .default, handler: nil))
        present(ac, animated: true)
    }
}

