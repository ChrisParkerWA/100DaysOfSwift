//
//  GameScene.swift
//  PairsV2
//
//  Created by Chris Parker on 22/6/19.
//  Modified: 24/6/19 - Convert to 2 player mode.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import AVFoundation
import SpriteKit

class GameScene: SKScene {
    
    var cards = [Card]()  //  Holds all 52 card filenames.
    var gameCards = [Card]() //   Stores random selection of 16 filenames twice!!!
    //  Stores cards (nodes) placed in player winning stacks to enable them to be removed from Parent()
    var playerStacks = [SKNode]()
    
    var gameCard: SKSpriteNode!
    var reverseOfCard: SKSpriteNode!
    //    var background: SKSpriteNode!
    
    var isTapping = false
    var isFirstCardSelected = false
    var faceCard1: SKNode!
    var faceCard2: SKNode!
    var backCard1: SKNode!
    var backCard2: SKNode!
    
    var cardsRemaing = 0
    
    var firstCardFlipped = false
    var secondCardFlipped = false
    
    var cardAppearDelay = 0.0
    
    let gameFont = "Marker Felt"
    var player1ScoreLabel: SKLabelNode!
    var player2ScoreLabel: SKLabelNode!
    var currentPlayerLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    
    var gameOverLabel: SKLabelNode!
    var gameScoreLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    var isGameOver = false
    
    var timer = Timer()
    var timeElapsed = 0 {
        didSet {
            timerLabel.text = "Time: \(formatTime(timeElapsed))"
        }
    }
    
    var player1score = 0 {
        didSet {
            player1ScoreLabel.text = "Player 1 Score: \(player1score)"
        }
    }
    
    var player2score = 0 {
        didSet {
            player2ScoreLabel.text = "Player 2 Score: \(player2score)"
        }
    }
    var currentPlayer = 1 {
        didSet {
            if currentPlayer == 1 {
                currentPlayerLabel.text = "<<<<< Current Player"
            } else {
                currentPlayerLabel.text = "Current Player >>>>>"
            }
        }
    }
    
    //  Card center co-ordinates for card store pile
    var player1CardPileOriginX = 20 + 55
    var playerCardPileOriginY = 768 - 25 - 84       // Same for both card piles
    var player1CardXOffset = 0
    var player1CardPile: CGPoint!
    var player1CardPileZposition = 0
    
    var player2CardPileOriginX = 768 - 25 - 84
    var player2CardXOffset = 0
    var player2CardPile: CGPoint!
    var player2CardPileZposition = 0
    
    var cardPileOffsetValue = 20
    
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor(hue: 0.3, saturation: 0.3, brightness: 0.25, alpha: 1)
        self.physicsWorld.gravity = .zero
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setUpGame()
            self.startGame()
        }
    }
    
    func startGame() {
        
        isFirstCardSelected = false
        firstCardFlipped = false
        secondCardFlipped = false
        player1score = 0
        player2score = 0
        currentPlayer = 1
        timeElapsed = 0
        cardAppearDelay = 0.0
        //  Remove each card node from play
        for node in playerStacks {
            node.removeFromParent()
        }
        //  then delete contents of array
        playerStacks.removeAll()
        player1CardXOffset = 0
        player2CardXOffset = 0
        player1CardPileZposition = 0
        player2CardPileZposition = 12
        
        selectCards()
        addBackCards()
        dealCards()
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
                
        player1ScoreLabel = SKLabelNode(fontNamed: gameFont)
        player1ScoreLabel.horizontalAlignmentMode = .left
        player1ScoreLabel.fontSize = 18
        player1ScoreLabel.position = CGPoint(x: 8, y: 750)
        addChild(player1ScoreLabel)
        
        player2ScoreLabel = SKLabelNode(fontNamed: gameFont)
        player2ScoreLabel.horizontalAlignmentMode = .right
        player2ScoreLabel.fontSize = 18
        player2ScoreLabel.position = CGPoint(x: 1016, y: 750)
        addChild(player2ScoreLabel)
        
        timerLabel = SKLabelNode(fontNamed: gameFont)
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.fontSize = 18
        timerLabel.position = CGPoint(x: 512, y: 750)
        addChild(timerLabel)
        
        currentPlayerLabel = SKLabelNode(fontNamed: gameFont)
        currentPlayerLabel.horizontalAlignmentMode = .center
        currentPlayerLabel.fontSize = 18
        currentPlayerLabel.position = CGPoint(x: self.frame.width / 4, y: 750)
        addChild(currentPlayerLabel)
        
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
                        // Separate filename prefix from the filenae extension using the '.' as the separator
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
        
        while cardCounter <= 12 {
            let randomCard = cards.randomElement()
            if !gameCards.contains(randomCard!) {
                gameCards.append(randomCard!)
                gameCards.append(randomCard!)
                cardCounter += 1
            }
        }
        //  Shuffle the selected cards array
        gameCards.shuffle()
        cardsRemaing = gameCards.count
    }
    
    func addBackCards() {
        //  1. Add selected cards to a point just below the playing surface
        //  2. These are to be animated rapidly onto the playing surface in a fan shape
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
    
    
    func dealCards() {
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
        var yCord = frameHeight - topPadding - cardHeight / 2 - yOffset
        
        playShuffleSound()
        //  Play the shuffle sound again in 2 seconds from .now()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.playShuffleSound()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.playShuffleSound()
        }
        
        for node in nodes(at: cardStackPosition) {
            
            slideCardIntoPosition(node: node, destination: CGPoint(x: xCord, y: yCord))
            xCord += xOffset
            if xCord > rightLimit  {
                xCord = xStart
                yCord -= yOffset
            }
        }
    }
    
    func slideCardIntoPosition(node: SKNode, destination: CGPoint) {
        //  After each card is added to the playing surface the delay is incremented by 0.05
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
        let yCord = frameHeight - topPadding - (cardHeight / 2) - yOffset
        
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
            gameScoreLabel.removeFromParent()
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
                isTapping = true
                flip(position: location)
                isFirstCardSelected = true
            } else if isFirstCardSelected {
                //  Second card has been selected.
                isTapping = true
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
            secondCardFlipped = true
            //Flip the second cell cards over
            flipUp(backCard: backCard2, faceCard: faceCard2)
        }
        
        if firstCardFlipped && secondCardFlipped {
            //  Is there a match?
            if faceCard1.name == faceCard2.name {
                //  Match then remove cards from Game and increment score
                removeCardsFromPlay(backCard: backCard1, faceCard: faceCard1, cardCount: 1)
                removeCardsFromPlay(backCard: backCard2, faceCard: faceCard2, cardCount: 2)
                firstCardFlipped = false
                secondCardFlipped = false
                isFirstCardSelected = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.playCorrectSound()
                }
                switch currentPlayer {
                case 1:
                    player1score += 1
                case 2:
                    player2score += 1
                default:
                    break
                }
                
                cardsRemaing -= 2       //  Always a multiple of two.
                if cardsRemaing == 0 {
                    //  Game Over
                    timer.invalidate()
                    isGameOver = true
                    gameOver()
                }
                
            } else {
                //  Flip cards back
                firstCardFlipped = false
                secondCardFlipped = false
                isFirstCardSelected = false
                flipBack(backCard: backCard1, faceCard: faceCard1)
                flipBack(backCard: backCard2, faceCard: faceCard2)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.playWrongSound()
                }
                
                switch currentPlayer {
                case 1:
                    currentPlayer = 2
                    let fadeOut = SKAction.fadeOut(withDuration: 0.15)
                    let moveRight = SKAction.move(to: CGPoint(x: (self.frame.size.width / 4) + (self.frame.size.width / 2), y: 750), duration: 0.5)
                    let fadeIn = SKAction.fadeIn(withDuration: 0.15)
                    let sequence = SKAction.sequence([fadeOut, moveRight, fadeIn])
                    currentPlayerLabel.run(sequence)
                case 2:
                    currentPlayer = 1
                    let fadeOut = SKAction.fadeOut(withDuration: 0.25)
                    let fadeIn = SKAction.fadeIn(withDuration: 0.25)
                    let moveLeft = SKAction.move(to: CGPoint(x: (self.frame.size.width / 4), y: 750), duration: 1)
                    let sequence = SKAction.sequence([fadeOut, moveLeft, fadeIn])
                    currentPlayerLabel.run(sequence)
                default: break
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
            let scaleInSlowAction = SKAction.scaleX(to: 0.001, duration: 0.15)
            let scaleInSeq2 = SKAction.sequence([scaleInSlowAction])
            backCard.run(scaleInSeq2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Scale out the face card slow.
            let scaleOutAction = SKAction.scaleX(to: 1, duration: 0.15)
            let scaleOutSeq3 = SKAction.sequence([scaleOutAction])
            faceCard.run(scaleOutSeq3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isTapping = false
        }
        
    }
    
    func flipBack(backCard: SKNode, faceCard: SKNode) {
        //  Animate the cards being turned over.
        
        playFlipSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //  Scale in the underlying face card
            let scaleInSlowAction = SKAction.scaleX(to: 0.001, duration: 0.15)
            let scaleInSeq1 = SKAction.sequence([scaleInSlowAction])
            faceCard.run(scaleInSeq1)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            // Scale out the back card.
            let scaleOutAction1 = SKAction.scaleX(to: 1, duration: 0.15)
            let scaleOutSeq2 = SKAction.sequence([scaleOutAction1])
            backCard.run(scaleOutSeq2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            // Scale out the face card underneath.
            let scaleOutAction2 = SKAction.scaleX(to: 1, duration: 0)
            let scaleOutSeq3 = SKAction.sequence([scaleOutAction2])
            faceCard.run(scaleOutSeq3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            self.isTapping = false
        }
        
    }
    
    func removeCardsFromPlay(backCard: SKNode, faceCard: SKNode, cardCount: Int) {
        //  set up some anmation to remove cards from play
        
        switch currentPlayer {
        case 1:
            faceCard.zPosition = CGFloat(player1CardPileZposition)
            player1CardPile = CGPoint(x: player1CardPileOriginX + player1CardXOffset, y: playerCardPileOriginY)
            let pulseOut = SKAction.scale(to: 1.2, duration: 0.15)
            let pulseIn = SKAction.scale(to: 1, duration: 0.15)
            //        let scaleOut = SKAction.scale(by: 0.001, duration: 0.4)
            let moveTo = SKAction.move(to: player1CardPile, duration: 0.15)
            let scaleIn = SKAction.scale(to: 0.85, duration: 0)
            let sequence = SKAction.sequence([pulseOut, pulseIn, pulseOut, pulseIn, pulseOut, pulseIn, moveTo, scaleIn])
            faceCard.run(sequence)
            if cardCount == 2 {
                player1CardXOffset += cardPileOffsetValue
            }
            player1CardPileZposition += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isTapping = false
            }
        case 2:
            faceCard.zPosition = CGFloat(player2CardPileZposition)
            player2CardPile = CGPoint(x: player2CardPileOriginX + player2CardXOffset, y: playerCardPileOriginY)
            let pulseOut = SKAction.scale(to: 1.2, duration: 0.15)
            let pulseIn = SKAction.scale(to: 1, duration: 0.15)
            //        let scaleOut = SKAction.scale(by: 0.001, duration: 0.4)
            let moveTo = SKAction.move(to: player2CardPile, duration: 0.15)
            let scaleIn = SKAction.scale(to: 0.85, duration: 0)
            let sequence = SKAction.sequence([pulseOut, pulseIn, pulseOut, pulseIn, pulseOut, pulseIn, moveTo,scaleIn])
            faceCard.run(sequence)
            if cardCount == 2 {
                player2CardXOffset += cardPileOffsetValue
            }
            player2CardPileZposition += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isTapping = false
            }
        default:
            break
        }
        
        playerStacks.append(faceCard)
        backCard.removeFromParent()
        
    }
    
    func gameOver() {
        var scoreText = ""
        if player1score > player2score {
            scoreText = "Player 1 won by \(player1score) to \(player2score)"
        } else if player2score > player1score {
            scoreText = "Player 2 won by \(player2score) to \(player1score)"
        } else {
            scoreText = "Game drawn"
        }
        if currentPlayer == 2 {
            currentPlayer = 1
            //  Move the currentPlayerLabel to the left
            let fadeOut = SKAction.fadeOut(withDuration: 0.25)
            let fadeIn = SKAction.fadeIn(withDuration: 0.25)
            let moveLeft = SKAction.move(to: CGPoint(x: (self.frame.size.width / 4), y: 750), duration: 1)
            let sequence = SKAction.sequence([fadeOut, moveLeft, fadeIn])
            currentPlayerLabel.run(sequence)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.gameOverLabel = SKLabelNode(text: "Game Over")
            self.gameOverLabel.fontName = self.gameFont
            self.gameOverLabel.fontSize = 100
            self.gameOverLabel.fontColor = .yellow
            self.gameOverLabel.zPosition = 8
            self.gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            self.gameOverLabel.xScale = 0.001
            self.gameOverLabel.yScale = 0.001
            self.gameOverLabel.name = "gameOver"
            self.addChild(self.gameOverLabel)
            
            let gameOverAppear = SKAction.scale(to: 1.0, duration: 0.5)
            self.gameOverLabel.run(gameOverAppear)
            
            self.gameScoreLabel = SKLabelNode(text: scoreText)
            self.gameScoreLabel.fontName = self.gameFont
            self.gameScoreLabel.fontSize = 70
            self.gameScoreLabel.fontColor = .yellow
            self.gameScoreLabel.zPosition = 8
            self.gameScoreLabel.position = CGPoint(x: self.size.width / 2, y: 260)
            self.gameScoreLabel.xScale = 0.001
            self.gameScoreLabel.yScale = 0.001
            self.gameScoreLabel.name = "gameScore"
            self.addChild(self.gameScoreLabel)
            
            let gameScoreAppear = SKAction.scale(to: 1.0, duration: 0.5)
            self.gameScoreLabel.run(gameScoreAppear)
            
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
    
    func playShuffleSound() {
        
        let shuffleSound = SKAction.playSoundFileNamed("shuffle.wav", waitForCompletion: false)
        
        run(shuffleSound)
    }
    
}
