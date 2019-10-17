//
//  GameScene.swift
//  P20Fireworks
//
//  Created by Chris Parker on 3/5/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//
//  Notes:  The games have been configured originally for iPads with a screen res of 1024 x 768
//          The iPad Pro 11 has a screen res of 1194 x 834.  Half that is 597 x 417

import SpriteKit

class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode!
    let gameFont = "Papyrus"
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var launchCount = 0 {
        didSet {
            launchLabel.text = "launch Count: \(launchCount)"
        }
    }
    let maxLaunches = 20
    
    var launchLabel: SKLabelNode!
    
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 597, y: 417)       //  Updated for iPad Pro  11
        background.blendMode = .replace
        background.zPosition = -1
        background.name = "background"
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: gameFont)
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: frame.width, y: frame.height - 40)       //  Updated for iPad Pro  11
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.fontSize = 36
        scoreLabel.zPosition = 1
        scoreLabel.name = "background"
        addChild(scoreLabel)
        
        launchLabel = SKLabelNode(fontNamed: "Arial")
        launchLabel.text = "Launches: 0"
        launchLabel.position = CGPoint(x: 5, y: 8)
        launchLabel.horizontalAlignmentMode = .left
        launchLabel.fontSize = 10
        launchLabel.zPosition = 1
        launchLabel.name = "background"
        addChild(launchLabel)
        
        startGame()
    }
    
    func startGame() {
        
        score = 0
        launchCount = 0
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)

    }
    
    @objc func launchFireworks() {
        
        let movementAmount: CGFloat = 1800
        
        if launchCount >= maxLaunches {
            gameOver()
        } else {
            launchCount += 1
            
            switch Int.random(in: 0...3) {
            case 0:
                // fire five, straight up
                createFirework(xMovement: 0, x: 512, y: bottomEdge)       //  Updated for iPad Pro 11
                createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)       //  Updated for iPad Pro 11
                createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)       //  Updated for iPad Pro 11
                createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)       //  Updated for iPad Pro 11
                createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)       //  Updated for iPad Pro 11
                
            case 1:
                // fire five, in a fan
                createFirework(xMovement: 0, x: 512, y: bottomEdge)       //  Updated for iPad Pro 11
                createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)       //  Updated for iPad Pro 11
                createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)       //  Updated for iPad Pro 11
                createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)       //  Updated for iPad Pro 11
                createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)       //  Updated for iPad Pro 11
                
            case 2:
                // fire five, from the left to the right
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
                
            case 3:
                // fire five, from the right to the left
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
                
            default:
                break
            }
        }
        
        
        
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // 1
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        // 2
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        // 3
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
            
        case 1:
            firework.color = .green
            
        case 2:
            firework.color = .red
            
        default:
            break
        }
        
        // 4
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        // 5  Speed changed from 200 to 220 for iPad Pro 11
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 220)
        node.run(move)
        
        // 6
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            emitter.name = "fuse"
            node.addChild(emitter)
        }
        
        // 7
        fireworks.append(node)
        addChild(node)
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        if nodesAtPoint.contains(where: { $0.name == "newGame"} ) {
            gameOverLabel.removeFromParent()
            newGameLabel.removeFromParent()
            startGame()
            return
        }
        
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            node.name = "selected"
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.colorBlendFactor = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 1000 {       //  Updated for iPad Pro 11.  Was 900
                // this uses a position high above so that rockets can explode off screen
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "explode") {
            explosion.position = firework.position
            addChild(explosion)
            
            let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.removeFromParent()])
            explosion.run(removeAfterDead)
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        if numExploded > 0 {
            run(SKAction.playSoundFileNamed("bang", waitForCompletion: false))
        }
        
        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
        
    }
    
    func gameOver() {
        gameTimer?.invalidate()
        
        for firework in fireworks {
            firework.removeFromParent()
        }
        fireworks.removeAll()
        
        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = gameFont
        gameOverLabel.fontSize = 70
        gameOverLabel.fontColor = .yellow
        gameOverLabel.zPosition = 8
        gameOverLabel.position = CGPoint(x: 597, y: 417)       //  Updated for iPad Pro 11
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
        newGameLabel.position = CGPoint(x: 597, y: -50)       //  Updated for iPad Pro 11
        newGameLabel.name = "newGame"
        addChild(newGameLabel)
        
        let newGameAppear = SKAction.move(to: CGPoint(x: 597, y: 70), duration: 0.5)
        
        newGameLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), newGameAppear]))
        
    }
    
}
