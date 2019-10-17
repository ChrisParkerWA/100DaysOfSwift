//
//  GameScene.swift
//  P11Pachinko
//
//  Created by Chris Parker on 18/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var ballCountLabel: SKLabelNode!
    
    //  Wrap up suggestion 1. Randomly select balls
    var allBalls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ballCount = 5 {
        didSet {
            ballCountLabel.text = "Balls left: \(ballCount)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var addBallsLabel: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 597, y: 417)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 1150, y: 781)
        addChild(scoreLabel)
        
        ballCountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballCountLabel.text = "Balls Left: 5"
        ballCountLabel.horizontalAlignmentMode = .right
        ballCountLabel.position = CGPoint(x: 1150, y: 746)
        addChild(ballCountLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 30, y: 781)
        addChild(editLabel)
        
        addBallsLabel = SKLabelNode(fontNamed: "Chalkduster")
        addBallsLabel.text = "Add Balls"
        addBallsLabel.horizontalAlignmentMode = .left
        addBallsLabel.position = CGPoint(x: 30, y: 746)
        addChild(addBallsLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 149.25, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 447.75, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 746.25, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 1044.75, y:0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 298.5, y: 0))
        makeBouncer(at: CGPoint(x: 597, y: 0))
        makeBouncer(at: CGPoint(x: 895.5, y: 0))
        makeBouncer(at: CGPoint(x: 1194, y: 0))
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            //  Wrap up suggestion 2: xLocation extracted from location
            let xLocation = location.x
            let objects = nodes(at: location)
            
            if objects.contains(addBallsLabel) {
                print("Add Balls Tapped")
                ballCount += 20
                return
            }
            if objects.contains(editLabel) {
                editingMode.toggle()
            } else {
                if editingMode {
                    //  Check if there is an existing box at the current location and if so, remove it.
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.name = "box"
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    addChild(box)
                } else {
                    if ballCount > 0 {
                        createBall(at: xLocation)
                        ballCount -= 1
                    } else {
                        gameOver()
                    }                    
                }
            }
        }
    }
    
    func createBall(at xLocation: CGFloat) {
        //  Wrap up suggestion 1. Randomly select balls using Int.random(in: Range)
        let randomNumber = Int.random(in: 0...allBalls.count - 1)
        let ball = SKSpriteNode(imageNamed: allBalls[randomNumber])
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        //  Wrap up suggestion 2: xLocation extracted from location and using frame height - 20 for ball start
        ball.position = CGPoint(x: xLocation, y: self.frame.height - 20)
        ball.name = "ball"
        addChild(ball)
    }
    
    func gameOver() {
        let ac = UIAlertController(title: "Game Over", message: "Press OK to play again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { ( action ) in
            while true {
                if let box = self.childNode(withName: "box") {
                    box.removeFromParent()
                } else {
                    break
                }
            }
            self.ballCount = 5
            self.score = 0
        }))
        
        if let vc = self.scene?.view?.window?.rootViewController {
            vc.present(ac, animated: true, completion: nil)
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" { 
            destroy(ball: ball)
            score += 10
            //  Bonus ball created
            let xLocation = CGFloat.random(in: 0...frame.width)
            createBall(at: xLocation)
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
        
        if object.name == "box" {
            object.removeFromParent()
        }
       
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        //  The guard statements ensure both bodyA and bodyB have nodes attached. If either of them don’t then this is a ghost collision and we can bail out immediately.
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
        
        if nodeA.name == "box" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "box" {
            collision(between: nodeB, object: nodeA)
        }
    }
}
