//
//  GameScene.swift
//  P23SwiftyNinja
//
//  Created by Chris Parker on 8/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import SpriteKit
import AVFoundation

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    
    //  Challenge 1: Define Magic numbers as constant properties of your class, giving them useful names.
    let spinRate: CGFloat = 3
    let xVelocityEdgeLow: Int = 8
    let xVelocityEdgeHigh: Int = 15
    let xVelocityMidLow: Int = 3
    let xVelocityMidHigh: Int = 5
    let yVelocityLow: Int = 24
    let yVelocityHigh: Int = 32
    let velocityMultiplier: Int = 40
    
    var gameScoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            gameScoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer: Timer?
    var timeLabel: SKLabelNode!
    var timeElapsed = 0 {
        didSet {
            timeLabel.text = "Time: \(formatTime(timeElapsed))"
        }
    }
    
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    var gameSpeedLabel: SKLabelNode!
    var gameSpeed: CGFloat = 0.0 {
        didSet {
            gameSpeedLabel.text = "Speed: " + String(format: "%.4f", gameSpeed)
        }
    }
    var livesLabel: SKLabelNode!
    var lives = 3 {
        didSet {
            livesLabel.text = "Lives: \(lives)"
        }
    }
    var livesImages = [SKSpriteNode]()
   
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    
    //  The popupTime property is the amount of time to wait between the last enemy being destroyed and a new one being created.
    var popupTime = 0.9
    //  The sequence property is an array of our SequenceType enum that defines what enemies to create.
    var sequence = [SequenceType]()
    //  The sequencePosition property is where we are right now in the game.
    var sequencePosition = 0
    //  The chainDelay property is how long to wait before creating a new enemy when the sequence type is .chain or .fastChain. Enemy chains don't wait until the previous enemy is offscreen before creating a new one, so it's like throwing five enemies quickly but with a small delay between each one.
    var chainDelay = 3.0
    //  The nextSequenceQueued property is used so we know when all the enemies are destroyed and we're ready to create more.
    var nextSequenceQueued = true
    var isGameEnded = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        
        createLabels()
        createLives()
        createSlices()
        startGame()
    }
    
    func startGame() {
        
        isGameEnded = false
        score = 0
        lives = 3
        popupTime = 0.9
        sequence = [SequenceType]()
        sequencePosition = 0
        chainDelay = 3.0
        physicsWorld.speed = 0.5
        gameSpeed = physicsWorld.speed
        activeEnemies.removeAll(keepingCapacity: true)
        sequence.removeAll(keepingCapacity: true)
        nextSequenceQueued = true
        timeElapsed = 0
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
    
        //  Reset lives images to 'alive'.
        for i in 0..<3 {
            livesImages[i].texture = SKTexture(imageNamed: "sliceLife")
        }
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        //  Create random sequence list.
        for _ in 0 ... 1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    @objc func updateGameTimer() {
        timeElapsed += 1
    }
    
    func formatTime(_ elaspsedTime: Int) -> String {
        let seconds = elaspsedTime % 60
        let minutes = elaspsedTime / 60
        
        return seconds < 10 ? "\(minutes):0\(seconds)" : "\(minutes):\(seconds)"
    }
    
    func createLabels() {
        gameScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameScoreLabel.horizontalAlignmentMode = .left
        gameScoreLabel.fontSize = 26
        addChild(gameScoreLabel)
        
        gameScoreLabel.position = CGPoint(x: 8, y: 8)
        score = 0
        
        timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.fontSize = 26
        addChild(timeLabel)
        
        timeLabel.position = CGPoint(x: 8, y: 35)
        
        gameSpeedLabel = SKLabelNode(fontNamed: "Arial")
        gameSpeedLabel.horizontalAlignmentMode = .right
        gameSpeedLabel.fontSize = 10
        gameSpeedLabel.fontColor = .white
        addChild(gameSpeedLabel)
        
        gameSpeedLabel.position = CGPoint(x: frame.width - 10, y: 18)
        gameSpeed = 0
        
        livesLabel = SKLabelNode(fontNamed: "Arial")
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.fontSize = 10
        livesLabel.fontColor = .white
        addChild(livesLabel)
        
        livesLabel.position = CGPoint(x: frame.width - 10, y: 30)
        lives = 3
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720) 
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            
            switch node.name {
                
            case "enemy":
                //  Destroy the penguin
                //  Create a particle effect over the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        emitter.removeFromParent()
                    }
                }
                
                //  Clear its node name so that it can't be swiped repeatedly.
                node.name = ""
                
                //  Disable the isDynamic of its physics body so that it doesn't carry on falling.
                node.physicsBody?.isDynamic = false
                
                //  Make the penguin scale out and fade out at the same time.
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                //  After making the penguin scale out and fade out, we should remove it from the scene.
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                //  Add one to the player's score.
                score += 1
                showScore(1, at: node.position)
                
                //  Remove the enemy from our activeEnemies array.
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                //  Play a sound so the player knows they hit the penguin.
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            case "bomb":
                //  destroy the bomb
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        emitter.removeFromParent()
                    }
                }
                
                //  Clear node name and disable isDynamic so that is does not continue to fall
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                //  Scale out, fade out and remove from parent
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                //  and remove from our activeEnemies array
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                //  Play a sound so the players knows they've hit a bomb.  Sadly it's GAME OVER.
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
                
            case "coin":
                //  Challenge 2: Create a new, fast-moving type of enemy that awards the player bonus points if they hit it.
                // Create a particle effect over the coin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitCoin") {
                    emitter.position = node.position
                    addChild(emitter)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        emitter.removeFromParent()
                    }
                }
                
                // Add Bonus Label
                let bonusLabel = SKLabelNode(text: "+10")
                bonusLabel.fontName = "Chalkduster"
                bonusLabel.fontSize = 100
                bonusLabel.fontColor = .yellow
                bonusLabel.position = node.position
                bonusLabel.zPosition = 1
                addChild(bonusLabel)
                
                let scaleOutBonus = SKAction.scale(to: 0.001, duration: 1)
                let fadeOutBonus = SKAction.fadeOut(withDuration: 1)
                let bonusGroup = SKAction.group([scaleOutBonus, fadeOutBonus])
                let sequence = SKAction.sequence([bonusGroup, .removeFromParent()])
                bonusLabel.run(sequence)
                
                //  Clear its node name so that it can't be swiped repeatedly.
                node.name = ""
                
                //  Disable the isDynamic of its physics body so that it doesn't carry on falling.
                node.physicsBody?.isDynamic = false
                
                //  Make the coin scale out and fade out at the same time.
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                //  After making the penguin scale out and fade out, we should remove it from the scene.
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                //  Add 10 to the player's score and as a bonus, return a life
                score += 10
                physicsWorld.speed /= 1.02
                gameSpeed = physicsWorld.speed
                addLife()
                
                //  Remove the enemy from our activeEnemies array.
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                //  Play a sound so the player knows they hit the penguin.
                run(SKAction.playSoundFileNamed("bang.wav", waitForCompletion: false))
                
            default:
                break
            }
           
        }
    }
    
    func showScore(_ targetValue: Int, at location: CGPoint) {
        var targetValueColor: SKColor!
        // Displays an animated score
        let scoreAlert = SKLabelNode()
        if targetValue < 0 {
            scoreAlert.text = "\(targetValue)"
            targetValueColor = .red
        } else {
            scoreAlert.text = "+\(targetValue)"
            targetValueColor = .yellow
        }
        scoreAlert.fontName = "Chalkduster"
        scoreAlert.fontSize = 75
        scoreAlert.fontColor = targetValueColor
        scoreAlert.position = location
        scoreAlert.zPosition = 100
        addChild(scoreAlert)

        let scaleOutBonus = SKAction.scale(to: 0.001, duration: 1)
        let fadeOutBonus = SKAction.fadeOut(withDuration: 1)
        let bonusGroup = SKAction.group([scaleOutBonus, fadeOutBonus])
        let sequence = SKAction.sequence([bonusGroup, .removeFromParent()])
        scoreAlert.run(sequence)
    }
    
    func subtractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration:0.1))
    }
    
    func addLife() {
        
        var life: SKSpriteNode
        
        if lives == 3 {
            return
        } else if lives == 2 {
            lives += 1
            life = livesImages[0]
        } else if lives == 1 {
            lives += 1
            life = livesImages[1]
        } else {
            lives += 1
            life = livesImages[2]
        }
        
        life.texture = SKTexture(imageNamed: "sliceLife")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration:0.1))
    }
    
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        isGameEnded = true
        gameTimer?.invalidate()
        lives = 0
        physicsWorld.speed = 0
        gameSpeed = physicsWorld.speed
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        for enemy in activeEnemies {
            enemy.removeFromParent()
        }
        
        //  Set up game ended label and play again lablel.
        
        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName =  "Chalkduster"
        gameOverLabel.fontSize = 70
        gameOverLabel.fontColor = .yellow
        gameOverLabel.zPosition = 1
        gameOverLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        gameOverLabel.xScale = 0.001
        gameOverLabel.yScale = 0.001
        addChild(gameOverLabel)
        
        let gameOverAppear = SKAction.scale(to: 1.0, duration: 0.5)
        gameOverLabel.run(gameOverAppear)
        
        newGameLabel = SKLabelNode(text: "New Game?")
        newGameLabel.fontName =  "Chalkduster"
        newGameLabel.fontSize = 50
        newGameLabel.fontColor = .yellow
        newGameLabel.zPosition = 1
        newGameLabel.position = CGPoint(x: frame.width / 2, y: -50)     //  Below the screen edge
        newGameLabel.name = "newGame"
        addChild(newGameLabel)
        
        let newGameAppear = SKAction.move(to: CGPoint(x: frame.width / 2, y: frame.height / 4), duration: 0.5)
        newGameLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), newGameAppear]))
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        //  Get the touch location
        let location = touch.location(in: self)
        
        let nodesAtPoint = nodes(at: location)
        if nodesAtPoint.contains(where: { $0.name == "newGame" }) {
            gameOverLabel.removeFromParent()
            newGameLabel.removeFromParent()
            startGame()
            return
        }
        //  Remove all existing points in the activeSlicePoints array, because we're starting fresh.
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        //   Add touch location to the activeSlicePoints array.
        activeSlicePoints.append(location)
        
        //  Call the redrawActiveSlice() method to clear the slice shapes.
        redrawActiveSlice()
        
        //  Remove any actions that are currently attached to the slice shapes. This will be important if they are in the middle of a fadeOut(withDuration:) action.
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        //  Set both slice shapes to have an alpha value of 1 so they are fully visible.
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    func redrawActiveSlice() {
        //  If we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear the shapes and exit the method.
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        //  If we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 – this stops the swipe shapes from becoming too long.
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        //  It needs to start its line at the position of the first swipe point, then go through each of the others drawing lines to each point.
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        //  Finally, update the slice shape paths so they get drawn using their designs – i.e., line width and color.
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
        
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        var enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...7)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }        
        
        enemy = SKSpriteNode()
        
        switch enemyType {
            
        case 0:
            // Create a new SKSpriteNode that will hold the fuse and the bomb image as children, setting its Z position to be 1.
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            //  Create the bomb image, name it "bomb", and add it to the container.
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            //  If the bomb fuse sound effect is playing, stop it and destroy it.
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            //  Create a new bomb fuse sound effect, then play it.
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            //  Create a particle emitter node, position it so that it's at the end of the bomb image's fuse, and add it to the container.
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            
        case 1...6:
            //  PENGUIN
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
            
        case 7:
            //  COIN
            // Challange 2: Create a new, fast-moving type of enemy that awards the player bonus points if they hit it.
            enemy = SKSpriteNode(imageNamed: "coin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "coin"
            
        default:
            break
        }
 
        //  Give the enemy a random position off the bottom edge of the screen.
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        //  Challenge 1: Define Magic numbers as constant properties of your class, giving them useful names.
        //  Create a random angular velocity, which is how fast something should spin.
        var randomAngularVelocity = CGFloat.random(in: -spinRate...spinRate )
        var randomXVelocity: CGFloat
    
        //  Create a random X velocity (how far to move horizontally) that takes into account the enemy's position.
        if randomPosition.x < 256 {
            randomXVelocity = CGFloat(Int.random(in: xVelocityEdgeLow...xVelocityEdgeHigh))
        } else if randomPosition.x < 512 {
            randomXVelocity = CGFloat(Int.random(in: xVelocityMidLow...xVelocityMidHigh))
        } else if randomPosition.x < 768 {
            randomXVelocity = CGFloat(-Int.random(in: xVelocityMidLow...xVelocityMidHigh))
        } else {
            randomXVelocity = CGFloat(-Int.random(in: xVelocityEdgeLow...xVelocityEdgeHigh))
        }
        
        //  Create a random Y velocity just to make things fly at different speeds.
        var randomYVelocity = CGFloat(Int.random(in: yVelocityLow...yVelocityHigh))
        
        //  Challenge 3:  Make the coin angular velocity and trajectory marginally faster than the penguin or bomb.
        if enemy.name == "coin" {
            randomXVelocity *= 1.15
            randomYVelocity *= 1.15
            randomAngularVelocity *= 1.4
        }
        
        //  Give all enemies a circular physics body where the collisionBitMask is set to 0 so they don't collide.
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: Int(randomXVelocity) * velocityMultiplier, dy: Int(randomYVelocity) * velocityMultiplier)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "coin" {
                        node.name = ""
                        subtractLife()
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        //  Count the number of bomb containers that exist in our game...
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        //  ... and stop the fuse sound if the answer is 0.
        if bombCount == 0 {
            // no bombs – stop the fuse sound!
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    func tossEnemies() {
        
        guard isGameEnded == false else { return }
        
        //  Gradually speed up the 'physicsWorld" so the game becomes more difficult.
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        gameSpeed = physicsWorld.speed
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()
            
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }
            
        case .fastChain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }

        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
}
