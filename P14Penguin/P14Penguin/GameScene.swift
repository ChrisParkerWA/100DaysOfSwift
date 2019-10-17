//
//  GameScene.swift
//  P14Penguin
//
//  Created by Chris Parker on 2/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var finalScore: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    var gameFont = "MarkerFelt-Thin"
    
    var popupTime = 0.85
    var numRounds = 0
    var numberOfRounds = 60
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)   //  Center in the middle
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "MarkerFelt-Thin")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        startGame()
        
    }
    
    func startGame() {
        
        popupTime = 0.85
        numRounds = 0
        score = 0
        isGameOver = false
        
        for slot in slots {
            slot.isVisible = false
            slot.isHit = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.createEnemy()
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        
        numRounds += 1
        
        if numRounds >= numberOfRounds {
            //  Means the game is over
            gameOver()
            isGameOver = true
            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
            self.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return }

        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(where: { $0.name == "newGame" }) {
            gameOverLabel.removeFromParent()
            newGameLabel.removeFromParent()
            finalScore.removeFromParent()
            startGame()
            return
        }
        
        if isGameOver { return }
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            
            if let smoke = SKEmitterNode(fileNamed: "Smoke") {
                smoke.position = location
                smoke.zPosition = 1
                addChild(smoke)
                
                let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
                smoke.run(removeAfterDead)
            }
            
            whackSlot.hit()
            
            if node.name == "charFriend" {
                // they shouldn't have whacked this penguin so take 5 off the score.
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                
            } else if node.name == "charEnemy" {
                // they should have whacked this one so add 1 to the score
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    func gameOver() {
        
        //  Allow time for the penguins already created to be hidden after the hidetime dealy then
        //  make sure that any still visible are made invisible
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [unowned self] in
//            for slot in self.slots {
//                if slot.isVisible {
//                    slot.hide()
//                }
//            }
//        }
        
        gameOverLabel = SKLabelNode(fontNamed: gameFont)
        gameOverLabel.text = "Game Over"
        gameOverLabel.zPosition = 1
        gameOverLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        gameOverLabel.xScale = 0.001
        gameOverLabel.yScale = 0.001
        gameOverLabel.name = "gameOver"
        addChild(gameOverLabel)
        
        let gameOverAppear = SKAction.scale(to: 1.0, duration: 0.5)
        gameOverLabel.run(gameOverAppear)
        
        run(SKAction.playSoundFileNamed("gameover.m4a", waitForCompletion: false))
        
        //            finalScore = SKLabelNode(fontNamed: "Chalkduster")
        finalScore = SKLabelNode(fontNamed: gameFont)
        finalScore.text = "Final Score: \(score)"
        finalScore.position = CGPoint(x: 512, y: 300)
        finalScore.horizontalAlignmentMode = .center
        finalScore.fontSize = 48
        finalScore.zPosition = 1
        finalScore.name = "finalScore"
        addChild(finalScore)
        
        newGameLabel = SKLabelNode(fontNamed: gameFont)
        newGameLabel.text = "New Game?"
        newGameLabel.position = CGPoint(x: frame.width / 2, y: -50)
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.fontSize = 40
        newGameLabel.zPosition = 1
        newGameLabel.name = "newGame"
        addChild(newGameLabel)
        
        let newGameAppear = SKAction.move(to: CGPoint(x: frame.width / 2, y: frame.height / 4), duration: 0.5)
        newGameLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), newGameAppear]))
    }

}
