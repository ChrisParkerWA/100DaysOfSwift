//
//  GameScene.swift
//  P26MarbleMaze
//
//  Created by Chris Parker on 10/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager?
    var accelerationMultiplier: Double = 25
    var isGameOver = false
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var levelLabel: SKLabelNode!
    var currentLevel = 1 {
        didSet {
            levelLabel.text = "Level: \(currentLevel)"
        }
    }
    
    var isStarSoundActive = false
    
    //  Challenge 2:  When the player finally makes it to the finish marker, nothing happens. What should happen? Well, that's down to you now. You could easily design several new levels and have them progress through.
    
    var maxLevel = 5
    var playerHomePosition: CGPoint?
    var levelNodes = [SKSpriteNode]()
    
    //  Challenge 3: Setup to cater for teleporting
    var isTeleporting = false
    
    override func didMove(to view: SKView) {

        backgroundColor = .black
        createBackground()
        createScoreLabel()
        createLevelLabel()
        loadLevel()
        lastTouchPosition = nil
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.name = "background"
        background.position = CGPoint(x: frame.width / 2, y: frame.width / 2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    
    func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.name = "score"
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)

    }
    
    func createLevelLabel() {
        levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelLabel.name = "level"
        levelLabel.text = "Level: 1"
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.position = CGPoint(x: frame.width / 2, y: 16)
        levelLabel.zPosition = 2
        addChild(levelLabel)
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level\(currentLevel)", withExtension: "txt") else {
            fatalError("Could not find level\(currentLevel).txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level\(currentLevel).txt from the app bundle.")
        }
        
        self.scene?.alpha = 0
        
        let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                switch letter {
                case "x":
                    // load wall
                    createWall(at: position)
                case "v":
                    // load vortex
                    createVortex(at: position)
                case "s":
                    // load star
                    createStar(at: position)
                case "f":
                    // load finish
                    createFinish(at: position)
                case "1":
                    // load teleport
                    createTeleport(at: position, isFirst: true)
                case "2":
                    // load teleport
                    createTeleport(at: position, isFirst: false)
                case "p":
                    // create Player
                    //  Note: This caters for level configuration text files containing the player position rather than hard coding the player position in just one position.
                    playerHomePosition = position
                    lastTouchPosition = position    //  Ensures that simulator gets the Player current position otherwise it tilts to where the last touch position from the previous level finish position.
                    createPlayer()
                    player.physicsBody?.isDynamic = false
                case " ":
                    // this is an empty space – do nothing!
                    break
                default:
                    fatalError("Unknown level letter: \(letter) at row: \(row) column: \(line)")
                }
            }
        }

        //  Fade the scene in
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 1.5)
        let sequence = SKAction.sequence([ fadeIn ])
        self.scene?.run(sequence)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.player.physicsBody?.isDynamic = true
        }
       
    }
    
    func createWall(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.name = "wall"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        //  NOTE: the rawValue extracts the number associated with the enum case name.
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        addChild(node)
        levelNodes.append(node)
    }
    
    func createVortex(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
        levelNodes.append(node)
    }
    
    func createStar(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
        levelNodes.append(node)
    }
    
    func createFinish(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
        levelNodes.append(node)
    }
    
    func createTeleport( at position: CGPoint, isFirst: Bool) {
        let node = SKSpriteNode(imageNamed: "teleport1")
        
        if isFirst == true {
            node.name = "teleport1"
        } else {
            node.name = "teleport2"
        }
        
//        let scaleDown = SKAction.scaleY(to: 0.6, duration: 0.3)
//        let scaleUp = SKAction.scaleY(to: 1.0, duration: 0.3)
//        let sequence = SKAction.sequence([scaleDown, scaleUp])
        //  This code creates two separate sequences that both apply to the node
        //  1. rotate the node by angle (radians) over time (seconds)
        //  2. scales down the node by a factor and scales UP the node to its original size
        //  3. Each sequence is repeated forever.
        let radians = CGFloat(Measurement(value: 360, unit: UnitAngle.degrees).converted(to: UnitAngle.radians).value)
        let rotate = SKAction.rotate(byAngle: -radians, duration: 3)
        let sequence1 = SKAction.sequence([rotate])
        node.run(SKAction.repeatForever(sequence1))
        
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let sequence2 = SKAction.sequence([scaleDown, scaleUp])
        node.run(SKAction.repeatForever(sequence2))
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
        levelNodes.append(node)
        
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = playerHomePosition!
        player.name = "player"
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.teleport.rawValue  //  The pipe cahracter causes the values to be combined.
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        //  Compiler directives change what code is used depending on target device.
        #if targetEnvironment(simulator)
        if let currentTouch = lastTouchPosition {
            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -accelerationMultiplier, dy: accelerometerData.acceleration.x * accelerationMultiplier)
        }
        #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        
        switch node.name {
            
        case "vortex":
            player.physicsBody?.isDynamic = false
            isGameOver = true
            playVortexSound()
            
            score -= 1
            showScore(-1, with: .red, at: node.position)
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
            
        case "star":
            
            score += 1
            showScore(1, with: .yellow, at: node.position)
            playStarSound()
            
            node.removeFromParent()
            
        case "finish":
            // Challenge 2: When the player finally makes it to the finish marker, nothing happens. What should happen? Well, that's down to you now. You could easily design several new levels and have them progress through.
            
            
            //  Increment score and add bonus for level completion.  Bonus increases for each subsequent level.
            score += 10 * (currentLevel * 2)
            showScore(10 * (currentLevel * 2), with: .green, at: node.position)
            playNextLevelSound()
 
            // Fade scene out
            let fadeOut = SKAction.fadeAlpha(to: 0, duration: 2)
            let fadeSequence = SKAction.sequence([fadeOut])
            self.scene?.run(fadeSequence)
            
            //  Move player to center of node and remove from scene
            player.physicsBody?.isDynamic = false
            let movePlayer = SKAction.move(to: node.position, duration: 0.15)
            let scalePlayer = SKAction.scale(to: 0.0001, duration: 0.15)
            let removePlayer = SKAction.removeFromParent()
            let moveSequence = SKAction.sequence([movePlayer, scalePlayer, removePlayer])
            player.run(moveSequence)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                
                //  Remove all curernt level nodes from the scene
                self?.levelNodes.forEach { $0.removeFromParent() }
                
                //  Clear levelNodes array
                self?.levelNodes.removeAll()
                
                //  Cycle back to level 1 if completed all available levels
                if self?.currentLevel == self?.maxLevel {
                    self?.currentLevel = 1
                } else {
                    self?.currentLevel += 1
                }
                
                self?.loadLevel()
            }
            
            
            
        case "teleport1":
            guard !isTeleporting else { break }
            if let teleport2 = self.childNode(withName: "teleport2") {
                teleportPlayer(from: node.position, to: teleport2.position)
            }
            
        case "teleport2":
            guard !isTeleporting else { break }
            isTeleporting = true
            if let teleport1 = self.childNode(withName: "teleport1") {
                teleportPlayer(from: node.position, to: teleport1.position)
            }
            
        default:
            break
        }
    }
    
    func playStarSound() {
        isStarSoundActive = true
        
        let starSound = SKAction.playSoundFileNamed("star.wav", waitForCompletion: true)
        
        run(starSound) { [weak self] in
            self?.isStarSoundActive = false
        }
    }
    
    func playVortexSound() {
        
        let vortexSound = SKAction.playSoundFileNamed("vortex.wav", waitForCompletion: false)
        
        run(vortexSound)
    }
    
    func playNextLevelSound() {
        
        let nextLevelSound = SKAction.playSoundFileNamed("nextLevel.wav", waitForCompletion: false)
        
        run(nextLevelSound)
    }
    
    
    func showScore(_ targetValue: Int, with targetColor: SKColor, at location: CGPoint) {
        // Displays an animated score
        let scoreAlert = SKLabelNode()
        if targetValue < 0 {
            scoreAlert.text = "\(targetValue)"
        } else {
            scoreAlert.text = "+\(targetValue)"
        }
        scoreAlert.fontName = "Chalkduster"
        scoreAlert.fontSize = 50
        scoreAlert.fontColor = targetColor
        scoreAlert.position = location
        scoreAlert.zPosition = 100
        addChild(scoreAlert)
        
        let appear = SKAction.group([
            SKAction.move(by: CGVector(dx: 0, dy: 40), duration: 0.25),
            SKAction.fadeIn(withDuration: 0.25)])
        let disappear = SKAction.group([
            SKAction.move(by: CGVector(dx: 0, dy: 40), duration: 0.25),
            SKAction.fadeOut(withDuration: 0.25)])
        let sequence = SKAction.sequence([appear, disappear, SKAction.removeFromParent()])
        scoreAlert.run(sequence)
    }
    
    // Challange 3: Add a new block type, such as a teleport that moves the player from one teleport point to the other. Add a new letter type in loadLevel(), add another collision type to our enum, then see what you can do.
    
    func teleportPlayer(from oldPosition: CGPoint, to newPosition: CGPoint) {
        
        // Change state to show teleport in progress
        isTeleporting = true
        playTeleportSound()
        
        // Temporarily disable physics on player
        player.physicsBody?.isDynamic = false
        
        // Move player into the centre of the teleport
        let moveToMiddle = SKAction.move(to: oldPosition, duration: 0.25)
        
        // Scale out the player
        let scaleOut = SKAction.scale(to: 0.0001, duration: 0.25)
        
        // Move player to other teleport position
        let moveToNewPosition = SKAction.move(to: newPosition, duration: 0)
        
        // Scale player back to full size
        let scaleIn = SKAction.scale(to: 1, duration: 0.25)
        
        // Restore physics on player
        let restorePhysicsBody = SKAction.run { [weak self] in
            self?.player.physicsBody?.isDynamic = true
        }
        
        // Wait for one second to prevent teleport 'ping-pong'
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isTeleporting = false
        }
        
        player.run(SKAction.sequence([moveToMiddle, scaleOut, moveToNewPosition, scaleIn, restorePhysicsBody]))
    }
    
    func playTeleportSound() {
    
        let teleportSound = SKAction.playSoundFileNamed("teleport.wav", waitForCompletion: false)
        
        run(teleportSound)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
}
