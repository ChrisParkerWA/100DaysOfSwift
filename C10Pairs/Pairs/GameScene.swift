//
//  GameScene.swift
//  Pairs
//
//  Created by Chris Parker on 22/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import AVFoundation
import SpriteKit

class GameScene: SKScene {
    
    var cards = [Card]()  //  Holds all 52 card filenames.
    var gameCards = [Card]() //   Stores random selection of 16 filenames twice!!!
    
    var gameCard: SKSpriteNode!
    var reverseOfCard: SKSpriteNode!
//    var background: SKSpriteNode!
    
    var isTapping = false
    var isFirstCardSelected = false
    var faceCard1: SKNode!
    var faceCard2: SKNode!
    var backCard1: SKNode!
    var backCard2: SKNode!
    
    var cardsRemaing = 32

    var firstCardFlipped = false
    var secondCardFlipped = false
    
    var cardAppearDelay = 0.0
    
    var gameFont = "Marker Felt"
    var gameScoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var isGameOver = false
    var newGameLabel: SKLabelNode!
    var timer = Timer()
    var timeElapsed = 0 {
        didSet {
            timerLabel.text = "Time: \(formatTime(timeElapsed))"
        }
    }

    var score = 0 {
        didSet {
            gameScoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self ] in
            self?.backgroundColor = UIColor(hue: 0.9, saturation: 0, brightness: 0.25, alpha: 1)
            
            self?.physicsWorld.gravity = .zero
            
            self?.setUpGame()
            self?.startGame()
        }
        
    }
    
    func startGame() {
        
        isFirstCardSelected = false
        firstCardFlipped = false
        secondCardFlipped = false
        score = 0
        timeElapsed = 0
        cardAppearDelay = 0.0
        
        selectCards()
        addBackCards()
        dealBackCards()
        addGameCards()
        startTimer()
    }
    
    func newGame() {
        startGame()
    }
    
    func setUpGame() {
        // Timer label - elapsed time
        // Gamme Over label
        // Play again label
        
//        background = SKSpriteNode(imageNamed: "background")
//        background.position = CGPoint(x: 512, y: 384)
//        background.blendMode = .replace
//        background.alpha = 0.5
//        background.zPosition = -1
//        addChild(background)

        gameScoreLabel = SKLabelNode(fontNamed: gameFont)
        gameScoreLabel.horizontalAlignmentMode = .right
        gameScoreLabel.fontSize = 18
        gameScoreLabel.position = CGPoint(x: 1016, y: 750)
        addChild(gameScoreLabel)
        
        timerLabel = SKLabelNode(fontNamed: gameFont)
        timerLabel.horizontalAlignmentMode = .left
        timerLabel.fontSize = 18
        timerLabel.position = CGPoint(x: 8, y: 750)
        addChild(timerLabel)
        
        loadImages()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: .none, repeats: true)
    }
        
    @objc func updateTimer() {
        timeElapsed += 1
    }
    
    func formatTime(_ elaspsedTime: Int) -> String {
        let seconds = elaspsedTime % 60
        let minutes = elaspsedTime / 60
        
        return seconds < 10 ? "\(minutes):0\(seconds)" : "\(minutes):\(seconds)"
    }
    
    func loadImages() {
        let fm = FileManager.default
        
        //  Get a list of all the files in the App Bundle.
        if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
            //  If Files are found in the App folder then loop through the list
            for item in tempItems {
                //  For each file in the folder, if the filename contains 'Large' (4000 x 4000) then
                if item.contains("card") {
                    //  append that item to the array
                    
                    var filename = Card(filename: item)
                    if filename.filename != "back.png" {
                        // Seaparate filename prefix from the filenae extension using the '.' as the separator
                        let array = filename.filename.components(separatedBy: ".")
                        // reassign filename to the first element
                        filename.filename = array[0]
                        cards.append(filename)
                    }
                }
            }
        }
    }
    
    func selectCards() {
        
        //  Select 16 random cards from array cards and place them into gameCards
        gameCards.removeAll()
        
        var cardCounter = 1
        
        while cardCounter <= 16 {
            let randomCard = cards.randomElement()
            if !gameCards.contains(randomCard!) {
                gameCards.append(randomCard!)
                gameCards.append(randomCard!)
                cardCounter += 1
            }
        }
        //  Shuffle the selected cards array
        gameCards.shuffle()
    }
    
    func addBackCards() {
        
        //  2. This is to be animated rapidly as if all cards were appearing from below the center of the screen.
        let startPosition = CGPoint(x: frame.width / 2, y: -150)
        for _ in 0...gameCards.count - 1 {
            reverseOfCard = SKSpriteNode(imageNamed: "back")
            reverseOfCard.name = "back"
            reverseOfCard.size = CGSize(width: (reverseOfCard.size.width), height: (reverseOfCard.size.height ))
            reverseOfCard.position = startPosition
            reverseOfCard.zPosition = 2
            reverseOfCard.isHidden = false
            addChild(reverseOfCard!)
        }
    }
    
    
    func dealBackCards() {
        //  Deal the cards onto the playing surface face down starting at the top left of screen and and moving across and down.
        let cardStackPosition = CGPoint(x: frame.width / 2, y: -150)
        
        let leftRightPadding = 20
        let topPadding = 25
        let cardPadding = 15
        let cardWidth = 110
        let cardHeight = 168
        let frameHeight = 768
        let xOffset = cardWidth + cardPadding
        let yOffset = cardHeight + cardPadding
        let xStart = leftRightPadding + cardWidth / 2
        let rightLimit = leftRightPadding + cardWidth / 2 + xOffset * 7
        
        var xCord = xStart
        var yCord = frameHeight - topPadding - cardHeight / 2
        
        for node in nodes(at: cardStackPosition)  {
        
            slideCardIntoPosition(node: node, destination: CGPoint(x: xCord, y: yCord))
            xCord += xOffset
            if xCord > rightLimit  {
                xCord = xStart
                yCord -= yOffset
            }
        }
    }
    
    func slideCardIntoPosition(node: SKNode, destination: CGPoint) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + cardAppearDelay) {
            let moveAction = SKAction.move(to: destination, duration: 0.5)
            let moveSeq = SKAction.sequence([moveAction])
            node.run(moveSeq)
        }
        cardAppearDelay += 0.05
    }
    
    func addGameCards() {
        
        // place playing cards underneath from gameCards
        let leftRightPadding = 20
        let topPadding = 25
        let cardPadding = 15
        let cardWidth = 110
        let cardHeight = 168
        let frameHeight = 768
        let xOffset = cardWidth + cardPadding
        let yOffset = cardHeight + cardPadding
        let xStart = leftRightPadding + cardWidth / 2
        let rightLimit = leftRightPadding + cardWidth / 2 + xOffset * 7
        
        let xCord = xStart
        let yCord = frameHeight - topPadding - (cardHeight / 2)
        
        var card = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            for col in stride(from: yCord, through: topPadding + cardHeight / 2, by: -yOffset) {
                for row in stride(from: xCord, through: rightLimit, by: xOffset) {
                    let image = self.gameCards[card].filename
                    self.gameCard = SKSpriteNode(imageNamed: image)
                    self.gameCard.zPosition = 0
                    self.gameCard.name = self.gameCards[card].filename
                    self.gameCard.size = CGSize(width: (self.gameCard.size.width), height: (self.gameCard.size.height ))
                    self.gameCard.position = CGPoint(x: row, y: col)
                    self.gameCard.isHidden = false
                    self.addChild(self.gameCard!)
                    card += 1
                }
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        if tappedNodes.contains(where: { $0.name == "newGame"} ) {
            gameOverLabel.removeFromParent()
            newGameLabel.removeFromParent()
            isGameOver = false
            newGame()
            return
        }
        if !isGameOver {
            var nodesFound = false
            for _ in nodes(at: location) {
                nodesFound = true
            }
            if nodesFound {
                processSelectedCard(location: location)
            }
        }
    }
    
    func processSelectedCard(location: CGPoint) {
        //  Process the location and find nodes at that location
 
        if !isTapping {     //  Prevent user from tapping another pair ahead of time.
            if !isFirstCardSelected {
                //  First card has been selected.
                flip(position: location)
                isFirstCardSelected = true
            } else if isFirstCardSelected {
                //  Second card has been selected.
                flip(position: location)
            }
        }

    }

    func flip(position: CGPoint) {
        

        //  Identify the back and the face given they are at the same location
        if !firstCardFlipped {
            for node in nodes(at: position) {
                if node.name == "back" {
                    backCard1 = node
                } else {
                    faceCard1 = node
                }
            }
            print("\(backCard1.name!)1 and faceCard: \(faceCard1.name!)")
            firstCardFlipped = true
            // Flip the first cell cards over
            flipUp(backCard: backCard1, faceCard: faceCard1)
            
        } else {
            for node in nodes(at: position) {
                if node.name == "back" {
                    backCard2 = node
                } else {
                    faceCard2 = node
                }
            }
            print("\(backCard2.name!)2 and faceCard: \(faceCard2.name!)")
            secondCardFlipped = true
            //Flip the second cell cards over
            flipUp(backCard: backCard2, faceCard: faceCard2)
        }
        
        if firstCardFlipped && secondCardFlipped {
            //  Is there a match?
            if faceCard1.name == faceCard2.name {
                //  Match then remove cards from Game and increment score
                print("Match")
                removeCardsFromPlay(backCard: backCard1, faceCard: faceCard1)
                removeCardsFromPlay(backCard: backCard2, faceCard: faceCard2)
                firstCardFlipped = false
                secondCardFlipped = false
                isFirstCardSelected = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.playCorrectSound()
                }
                score += 2
                
                cardsRemaing -= 2       //  Always a multiple of two.
                if cardsRemaing == 0 {
                    //  Game Over
                    timer.invalidate()
                    isGameOver = true
                    gameOver()
                }
                
            } else {
                //  Flip cards back
                print("No Match")
                firstCardFlipped = false
                secondCardFlipped = false
                isFirstCardSelected = false
                flipBack(backCard: backCard1, faceCard: faceCard1)
                flipBack(backCard: backCard2, faceCard: faceCard2)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.playWrongSound()
                }
                

            }
        }

    }
    
    func flipUp(backCard: SKNode, faceCard: SKNode) {
        
        playFlipSound()
        
        //  Animate the cards being turned over.
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let scaleInFastAction = SKAction.scaleX(to: 0.001, duration: 0)
            let scaleInSeq1 = SKAction.sequence([scaleInFastAction])
            faceCard.run(scaleInSeq1)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //  Scale in the back card
            let scaleInSlowAction = SKAction.scaleX(to: 0.001, duration: 0.1)
            let scaleInSeq2 = SKAction.sequence([scaleInSlowAction])
            backCard.run(scaleInSeq2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Scale out the face card slow.
            let scaleOutAction = SKAction.scaleX(to: 1, duration: 0.1)
            let scaleOutSeq3 = SKAction.sequence([scaleOutAction])
            faceCard.run(scaleOutSeq3)
            self.isTapping = false
        }
        
    }
    
    func flipBack(backCard: SKNode, faceCard: SKNode) {
        //  Animate the cards being turned over.
        
        playFlipSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //  Scale in the underlying face card
            let scaleInSlowAction = SKAction.scaleX(to: 0.001, duration: 0.1)
            let scaleInSeq1 = SKAction.sequence([scaleInSlowAction])
            faceCard.run(scaleInSeq1)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            // Scale out the back card.
            let scaleOutAction1 = SKAction.scaleX(to: 1, duration: 0.1)
            let scaleOutSeq2 = SKAction.sequence([scaleOutAction1])
            backCard.run(scaleOutSeq2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            // Scale out the face card underneath.
            let scaleOutAction2 = SKAction.scaleX(to: 1, duration: 0.1)
            let scaleOutSeq3 = SKAction.sequence([scaleOutAction2])
            faceCard.run(scaleOutSeq3)
            self.isTapping = false
        }
        
    }
    
    func removeCardsFromPlay(backCard: SKNode, faceCard: SKNode) {
        //  set up some anmation to remove cards from play

        let pulseOut = SKAction.scale(to: 1.2, duration: 0.15)
        let pulseIn = SKAction.scale(to: 1, duration: 0.15)
        let scaleOut = SKAction.scale(by: 0.001, duration: 0.4)
        let sequence = SKAction.sequence([pulseOut, pulseIn, pulseOut, pulseIn, pulseOut, pulseIn, scaleOut])
        faceCard.run(sequence)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            backCard.removeFromParent()
            faceCard.removeFromParent()
        }
        
    }
    
    func gameOver() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.gameOverLabel = SKLabelNode(text: "Game Over")
            self.gameOverLabel.fontName = self.gameFont
            self.gameOverLabel.fontSize = 100
            self.gameOverLabel.fontColor = .yellow
            self.gameOverLabel.zPosition = 8
            self.gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            self.gameOverLabel.xScale = 0.001
            self.gameOverLabel.yScale = 0.001
            self.gameOverLabel.name = "background"
            self.addChild(self.gameOverLabel)
            
            let gameOverAppear = SKAction.scale(to: 1.0, duration: 0.5)
            self.gameOverLabel.run(gameOverAppear)
            
            self.newGameLabel = SKLabelNode(text: "New Game?")
            self.newGameLabel.fontName = self.gameFont
            self.newGameLabel.fontSize = 60
            self.newGameLabel.fontColor = .yellow
            self.newGameLabel.zPosition = 8
            self.newGameLabel.position = CGPoint(x: 512, y: -50)
            self.newGameLabel.name = "newGame"
            self.addChild(self.newGameLabel)
            
            let newGameAppear = SKAction.move(to: CGPoint(x: 512, y: 150), duration: 0.5)
            
            self.newGameLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), newGameAppear]))
        }
    }
    
    func playCorrectSound() {
        
        let correctSound = SKAction.playSoundFileNamed("correct.wav", waitForCompletion: false)
        
        run(correctSound)
    }
    
    func playWrongSound() {
        
        let wrongSound = SKAction.playSoundFileNamed("wrong.wav", waitForCompletion: false)
        
        run(wrongSound)
    }
    
    func playFlipSound() {
        
        let flipSound = SKAction.playSoundFileNamed("flip.wav", waitForCompletion: false)
        
        run(flipSound)
    }
    
}
