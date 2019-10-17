//
//  WhackSlot.swift
//  P14Penguin
//
//  Created by Chris Parker on 2/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    
    var isVisible = false
    var isHit = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        if charNode.position.y < -90 {
            charNode.position.y = -90
//            print("Node position adjusted: \(charNode.position)")
        }
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        //  Create mud effect where penuin pops up
        createMud(at: charNode.position, isPenguinShowing: true)
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [unowned self] in
            self.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        if isHit { return }
        
        //  Create mud effect where penuin pops down
        createMud(at: charNode.position, isPenguinShowing: false)
        
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.05)
        let delay = SKAction.wait(forDuration: 0.25)
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
        let hideSeq = SKAction.sequence([hide, delay, notVisible])
        charNode.run(hideSeq)
        
    }
    
    func hit() {
        isHit = true
        
//        let firstDelay = SKAction.wait(forDuration: 0.25)
//        let secondDelay = SKAction.wait(forDuration: 0.75)
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
        let sequence = SKAction.sequence([delay, hide, delay, notVisible])
        charNode.run(sequence)
    }
    
    func createMud(at position: CGPoint, isPenguinShowing: Bool) {
        let xPosition = position.x
        let yPosition = position.y
        
        if let mud = SKEmitterNode(fileNamed: "Mud") {
            if isPenguinShowing {
                mud.position = CGPoint(x: xPosition, y: yPosition + 85)
            } else {
                mud.position = CGPoint(x: xPosition, y: yPosition)
            }
            mud.name = "mud"
            mud.zPosition = 0
            addChild(mud)
//            print(position, mud.position, isPenguinShowing)

            let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.removeFromParent()])
            mud.run(removeAfterDead)
        }
    }
    
}
