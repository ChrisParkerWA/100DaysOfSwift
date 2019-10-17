//
//  GameScene.swift
//  C6ShootEmUp
//
//  Created by Chris Parker on 17/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //  Constants
    
    let leftStartingX: CGFloat = 50
    let rightStartingX: CGFloat = 1150
    
    let moveRightAction = SKAction.move(by: CGVector(dx: 1200, dy: 0), duration: 3.5)
    let moveLeftAction = SKAction.move(by: CGVector(dx: -1200, dy: 0), duration: 3.5)
    
    let gameFont = "Papyrus"
    let goodDucks = ["target1","target2","target3"]
    let pollie = ["target5", "target6", "target7", "target8", "target9",
                  "target10", "target11", "target12", "target13", "target14"]
    
    //  Variables
    
    var scoreLabel: SKLabelNode!
    
    var clip: SKSpriteNode!
    var ammo = 6 {
        didSet {
            clip.texture = SKTexture(imageNamed: "ammo\(ammo)")
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var addTargetTimer: Timer?
    var targetTimeInterval = 0.5
    
    var gameTimer: Timer?
    var timerLabel: SKLabelNode!
    let gameTime = 120
    var timeRemaining = 120 {
        didSet {
            timerLabel.text = "Time: \(timeRemaining)"
        }
    }
    
    var targets: [SKSpriteNode] = []
    
    var isGameOver = false
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        print(CGFloat((self.view?.frame.width)!))
        print(CGFloat((self.view?.frame.height)!))
        
        let woodBackground = SKSpriteNode(imageNamed: "wood-background")
        woodBackground.position = CGPoint(x: 512, y: 384)   //  Center in the middle
        woodBackground.size = view.frame.size
        woodBackground.zPosition = -8
        woodBackground.name = "background"
        addChild(woodBackground)
        
        let grassAndTrees = SKSpriteNode(imageNamed: "grass-trees")
        grassAndTrees.position = CGPoint(x: 512, y: 460)   //  Centered and positioned vertically
        grassAndTrees.size = CGSize(width: view.frame.width, height: grassAndTrees.frame.height)
        grassAndTrees.zPosition = -6
        grassAndTrees.name = "background"
        addChild(grassAndTrees)
        
        let waterBG = SKSpriteNode(imageNamed: "water-bg")
        waterBG.position = CGPoint(x: 512, y: 300)   //  Center in the middle
        waterBG.size = CGSize(width: view.frame.width, height: waterBG.frame.height)
        waterBG.zPosition = -4
        waterBG.name = "background"
        addChild(waterBG)
        
        let waterFG = SKSpriteNode(imageNamed: "water-fg")
        waterFG.position = CGPoint(x: 512, y: 200)   //  Center in the middle
        waterFG.size = CGSize(width: view.frame.width, height: waterFG.frame.height)
        waterFG.zPosition = -2
        waterFG.name = "background"
        addChild(waterFG)
        
        let animateWaterLeft = SKAction.move(by: CGVector(dx: -50, dy: 0), duration: 0.3)
        let animateWaterRight = SKAction.move(by: CGVector(dx: 50, dy: 0), duration: 0.3)
        
        let animateWaterLeftRight = SKAction.repeatForever(SKAction.sequence([animateWaterLeft,animateWaterRight]))
        let animateWaterRightLeft = SKAction.repeatForever(SKAction.sequence([animateWaterRight,animateWaterLeft]))
        
        waterFG.run(animateWaterLeftRight)
        waterBG.run(animateWaterRightLeft)
        
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: 512, y: 400)   //  Center in the middle
        curtains.size = view.frame.size
        curtains.zPosition = 0
        curtains.name = "background"
        addChild(curtains)
        
        timerLabel = SKLabelNode(fontNamed: gameFont)
        timerLabel.text = "Time: 0"
        timerLabel.position = CGPoint(x: 512, y: 725)
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.fontSize = 48
        timerLabel.zPosition = 1
        timerLabel.name = "background"
        addChild(timerLabel)
        
        clip = SKSpriteNode(imageNamed: "ammo0")
        clip.position = CGPoint(x: 100, y: 735)
        clip.size = CGSize(width: clip.frame.width, height: clip.frame.height)
        clip.zPosition = 1
        clip.name = "clip"
        addChild(clip)
        
        scoreLabel = SKLabelNode(fontNamed: gameFont)
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 1000, y: 725)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.fontSize = 48
        scoreLabel.zPosition = 1
        scoreLabel.name = "background"
        addChild(scoreLabel)
        
        startGame()
        
    }
    
    func startGame() {        
        
        score = 0
        ammo = 6
        timeRemaining = gameTime
        
        addTargetTimer?.invalidate()
        addTargetTimer = Timer.scheduledTimer(timeInterval: targetTimeInterval, target: self, selector: #selector(addTargetSprite), userInfo: nil, repeats: true)
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
        
        run(SKAction.playSoundFileNamed("reload", waitForCompletion: false))
        
    }
    
    @objc func addTargetSprite() {
        
        let sprite: SKSpriteNode = randomTarget()
        sprite.physicsBody = SKPhysicsBody()
        sprite.physicsBody?.isDynamic = false
        
        switch Int.random(in: 0...3) {
            
        case 0: //  Row 4
            sprite.zPosition = TargetZPosition.row4.rawValue
            sprite.position = CGPoint(x: leftStartingX, y: TargetRow.row4.rawValue)
            addChild(sprite)
            sprite.run(moveRightAction)
            
        case 1: // Row 3
            sprite.xScale = -1 // Flip to face left
            sprite.zPosition = TargetZPosition.row3.rawValue
            sprite.position = CGPoint(x: rightStartingX, y: TargetRow.row3.rawValue)
            addChild(sprite)
            sprite.run(moveLeftAction)
            
        case 2: //  Row 2
            sprite.zPosition = TargetZPosition.row2.rawValue
            sprite.position = CGPoint(x: leftStartingX, y: TargetRow.row2.rawValue)
            addChild(sprite)
            sprite.run(moveRightAction)
            
        case 3: // Row 1
            sprite.xScale = -1 // Flip to face left
            sprite.zPosition = TargetZPosition.row1.rawValue
            sprite.position = CGPoint(x: rightStartingX, y: TargetRow.row1.rawValue)
            addChild(sprite)
            sprite.run(moveLeftAction)
        default:
            break
        }
        
        targets.append(sprite)        
    }
    
    func randomTarget() -> SKSpriteNode {
        
        var sprite: SKSpriteNode!
        
        switch Int.random(in: 0...19) {
            
        case 0...4: //  Good Duck 25% chance
            sprite = SKSpriteNode(imageNamed: goodDucks.randomElement()!)
            sprite.name = "goodTarget"
            
        case 5...9: //  Nail a pollie 25% chance
            sprite = SKSpriteNode(imageNamed: pollie.randomElement()!)
            sprite.name = "pollie"
            
        case 10...17: //    Bad Duck 40% chance
            sprite = SKSpriteNode(imageNamed: "target4")
            sprite.name = "badTarget"
            
        case 18...19: //    Target 10% chance
            sprite = SKSpriteNode(imageNamed: "target0")
            sprite.name = "target"
            
        default:
            break
        }
        
        return sprite
    }
    
    @objc func updateGameTimer() {
        timeRemaining -= 1
        if timeRemaining == 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        gameTimer?.invalidate()
        addTargetTimer?.invalidate()
        isGameOver = true
        
        for target in targets {
            target.removeFromParent()
        }
        
        targets.removeAll()
        
        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = gameFont
        gameOverLabel.fontSize = 70
        gameOverLabel.fontColor = .yellow
        gameOverLabel.zPosition = 8
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.xScale = 0.001
        gameOverLabel.yScale = 0.001
        gameOverLabel.name = "background"
        addChild(gameOverLabel)
        
        let gameOverAppear = SKAction.scale(to: 1.0, duration: 0.5)
        gameOverLabel.run(gameOverAppear)
        
        newGameLabel = SKLabelNode(text: "New Game?")
        newGameLabel.fontName = gameFont
        newGameLabel.fontSize = 50
        newGameLabel.fontColor = .yellow
        newGameLabel.zPosition = 8
        newGameLabel.position = CGPoint(x: 512, y: -50)
        newGameLabel.name = "newGame"
        addChild(newGameLabel)
        
        let newGameAppear = SKAction.move(to: CGPoint(x: 512, y: 150), duration: 0.5)
        
        newGameLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), newGameAppear]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(where: { $0.name == "newGame"} ) {
            gameOverLabel.removeFromParent()
            newGameLabel.removeFromParent()
            isGameOver = false
            startGame()
            return
        }
        
        if !isGameOver {            
            
            if tappedNodes.contains(where: {$0.name == "clip"}) {
                reload()
                return
            }
            
            //  Shoot and return true if ammo remaining
            guard shoot(at: location) else { return }
            
            for case let node as SKSpriteNode in tappedNodes  {
                
                switch node.name {
                case "goodTarget":
                    score += 5
                    spriteHit(node: node, location: location, targetValue: 5)
                    
                case "pollie":
                    score += 10
                    spriteHit(node: node, location: location, targetValue: 10)
                    
                case "badTarget":
                    score -= 20
                    spriteHit(node: node, location: location, targetValue: -20)
                    
                case "target":
                    score += 20
                    spriteHit(node: node, location: location, targetValue: 20)
                    
                default:
                    continue
                }
                
            }
        }
        
    }
    
    func shoot(at position: CGPoint) -> Bool {
        
        if ammo > 0 {
            run(SKAction.playSoundFileNamed("shot", waitForCompletion: false))
            
            let crosshair = SKSpriteNode(imageNamed: "cursor")
            crosshair.zPosition = 0
            crosshair.position = position
            addChild(crosshair)
            
            let removeCrosshair = SKAction.run {
                crosshair.removeFromParent()
            }
            
            crosshair.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),removeCrosshair]))
            
            ammo -= 1
            return true
        } else {
            run(SKAction.playSoundFileNamed("empty", waitForCompletion: false))
            return false
        }
    }
    
    func spriteHit(node: SKSpriteNode, location: CGPoint, targetValue: Int) {
        
        if let smoke = SKEmitterNode(fileNamed: "Explosion") {
            smoke.position = location
            smoke.zPosition = -1
            addChild(smoke)

            let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.removeFromParent()])
            smoke.run(removeAfterDead)
        }
        
        //  Display value for the target
        showScore(targetValue, at: location)
        
        node.removeAllActions()
        node.name = "hit"
        
        let reduceSize = SKAction.scale(by: 0.85, duration: 0.05)
        let applyGravity = SKAction.run {
            node.physicsBody?.isDynamic = true
        }
        
        let sequence = SKAction.sequence([
            reduceSize,
            SKAction.wait(forDuration: 0.2),
            applyGravity,
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
            ])
        
        node.run(sequence)
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
            targetValueColor = .white
        }
        scoreAlert.fontName = "Chalkduster"
        scoreAlert.fontSize = 75
        scoreAlert.fontColor = targetValueColor
        scoreAlert.position = location
        scoreAlert.zPosition = 100
        addChild(scoreAlert)
        
        let appear = SKAction.group([
            SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.25),
            SKAction.fadeIn(withDuration: 0.25)])
        let disappear = SKAction.group([
            SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 0.25),
            SKAction.fadeOut(withDuration: 0.25)])
        let sequence = SKAction.sequence([appear, disappear, SKAction.removeFromParent()])
        scoreAlert.run(sequence)
    }
    
    func reload() {
        ammo = 6
        run(SKAction.playSoundFileNamed("reload", waitForCompletion: false))
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, target) in targets.enumerated().reversed() {
            if target.position.x < 0 || target.position.x > 1200 || target.position.y < 0 {
                targets.remove(at: index)
                target.removeFromParent()
            }
        }
    }
}
