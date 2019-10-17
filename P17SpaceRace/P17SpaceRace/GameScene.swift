//
//  GameScene.swift
//  P17SpaceRace
//
//  Created by Chris Parker on 14/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var enemyLabel: SKLabelNode!
    var readyLabel: SKLabelNode!
    
    var alertControllerIsPresenting = false //  Prevent attempts to present alertContoller multiple times
    
    var possibleEnemies = ["ball", "hammer", "tv", "mortein", "tyre", "tractor", "phone", "dummy"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var timerValue = 1.00
    var timerStarted = false

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var enemyCount = 0 {
        didSet {
            enemyLabel.text = "Enemy Count: \(enemyCount)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        //  Print out the screen resolution on the Console
        print("\(String(describing: self.view?.frame.width))")
        print("\(String(describing: self.view?.frame.height))")
        
        starfield = SKEmitterNode(fileNamed: "starfield")!      //  Force unwrapped because the file exists in the project
        starfield.position = CGPoint(x: 1024, y: 384)           //  Center of the RHS of the screen
        starfield.advanceSimulationTime(10)                     //  Starfield will already occupy the whole screen
        starfield.zPosition = -1                                //  Place it behind the rest
        addChild(starfield)
        
        createPlayer()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)             //  Just up from the bottom left of the screen.
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0                                               //  Triggers property observer to update score label.
        
        enemyLabel = SKLabelNode(fontNamed: "Chalkduster")
        enemyLabel.position = CGPoint(x: 1008, y: 16)             //  Just up from the bottom right of the screen.
        enemyLabel.horizontalAlignmentMode = .right
        addChild(enemyLabel)
        
        enemyCount = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)           //  Zero gravity
        physicsWorld.contactDelegate = self                     //  Relies on delegate to be added to class.
        
        startGame()
    }
    
    func startGame() {
        readyLabel = SKLabelNode(text: "Ready, Set, GO")
        readyLabel.fontName = "Chalkduster"
        readyLabel.fontSize = 40
        readyLabel.fontColor = .red
        readyLabel.zPosition = 1
        readyLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        readyLabel.name = "ready"
        addChild(readyLabel)
    }
    
    func startTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        timerStarted = true
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)                   //  half way up the left of screen
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1300, y: Int.random(in: 50...718))
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.addChild(sprite)
        }
        
        enemyCount += 1
        
        if enemyCount == 20 {
            gameTimer?.invalidate()
            timerStarted = false
            enemyCount = 0
            timerValue -= 0.1
            startTimer()
        }
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)    //  Push left at a constant speed
        sprite.physicsBody?.angularVelocity = 5                     //  Spin at a constant rate
        sprite.physicsBody?.linearDamping = 0                       //  Wont slow down movememt left (in space)
        sprite.physicsBody?.angularDamping = 0                      //  Spin rate remains constant
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {                             //  Should be off the screen
                node.removeFromParent()                             //  so get rid of it.
            }
        }
        
        if !isGameOver && timerStarted {
            score += 1
        }
 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        //  Get the touch location
        let location = touch.location(in: self)
        
        let nodesAtPoint = nodes(at: location)
        if nodesAtPoint.contains(where: { $0.name == "ready" }) {
            readyLabel.removeFromParent()
            startTimer()
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //  Stop the player from cheating and lifting finger off to place in a new position on the screen
        //  by resetting the space ship back to the centre left of screen.
        player.position = CGPoint(x: 100, y: 384)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
        gameTimer?.invalidate()
        timerStarted = false
        
        if !alertControllerIsPresenting {
            restartGame()
        }
    }
    
    func restartGame() {
        let ac = UIAlertController(title: "Game Over", message: "Press OK to play again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { ( action ) in
            self.enemyCount = 0
            self.timerValue = 1.00
            self.score = 0
            self.isGameOver = false
            self.createPlayer()
            self.startGame()
            self.alertControllerIsPresenting = false
        }))
        
        alertControllerIsPresenting = true
        
        if let vc = self.scene?.view?.window?.rootViewController {
                vc.present(ac, animated: true, completion: nil)
        }
    }
    
}
