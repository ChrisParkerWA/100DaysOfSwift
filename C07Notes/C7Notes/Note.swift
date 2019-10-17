//
//  Note.swift
//  C7Notes
//
//  Created by Chris Parker on 12/5/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import Foundation

class Note: Codable {
    var text: String
    var date: Date
    
    init(text: String, date: Date) {
        self.text = text
        self.date = date
    }
    
    func title() -> String {
        
        //  In Notes, "New Note" is displayed where there is no text though a test is made in DetailViewConroller
        //  to not create a note with no text.
        guard !text.isEmpty else {
            return "New Note"
        }
        
        // In Notes, the first 45(ish) characters are displayed as the title in the cell and truncated.
        var length: Int
        
        // If the length of the text is <= 45 characters, get the actual length for the title, or use 45 as a maximum length
        if text.count <= 45 {
            length = text.count
        } else {
            length = 45
        }
        
        // If there are any line breaks in the text, return only the text up to the first line break
        let firstCharacters = text.prefix(length)
        if firstCharacters.contains("\n") {
            let lines = firstCharacters.components(separatedBy: "\n")
            return lines[0]
        } else {
            return String(firstCharacters)
        }
    }
    
    func subTitle() -> String {
        
        // If there is a line break in the first 45 characters, uses the second line as the subTitle
        // If there is no line break, "No additional text" is displayed, as in the Notes App
        var returnText = ""
        
        if text.count <= 45 {
            if text.contains("\n") {
                let lines = text.components(separatedBy: "\n")
                if lines.count > 1 {
                    //  Find the first line containing text and return that line
                    for line in 1...lines.count - 1 {
                        if lines[line] != "" {
                            returnText = lines[line]
                            break
                        } else {
                            returnText = "No additional text"
                        }
                    }
                }
            } else {
                returnText = "No additional text"
            }
        } else {
            //  If text is over 45 characters, 1) Start the subtitle where there is a line break within the
            //  first 45 characters or 2) start the subTitle after the first space beyond 45 characters,
            //  so as not to split words
            if text.contains("\n") {
                let lines = text.components(separatedBy: "\n")
                //  Start at the second sentence given that the first was grabbed by title()
                for index in 1...lines.count - 1 {
                    if lines[index] != "" {
                        returnText = lines[index]
                        break
                    }
                }
            } else {
                let startIndex = text.index(text.startIndex, offsetBy: 45)
                let bodyText = String(text[startIndex...])
                
                if let indexOfFirstSpace = bodyText.firstIndex(of: " ") {
                    let indexAfterFirstSpace = bodyText.index(after: indexOfFirstSpace)
                    returnText = String(bodyText[indexAfterFirstSpace...])
                } else {
                    returnText = bodyText
                }
            }
           
        }
        return returnText
    }
    
    func dateString() -> String {
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "dd/MM/YYYY"
            return formatter.string(from: date)
        }
    }
    
}
