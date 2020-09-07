//
//  GameViewController.swift
//  P29ExplMonkeys
//
//  Created by Chris Parker on 19/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    @IBOutlet var player1ScoreLabel: UILabel!
    @IBOutlet var player2ScoreLabel: UILabel!
    @IBOutlet var windLabel: UILabel!
    
    var currentGame: GameScene?
    var currentPlayer = 0
    var player1Score = 0 {
        didSet {
            player1ScoreLabel.text = "Player1: \(player1Score)"
        }
    }
    var player2Score = 0 {
        didSet {
            player2ScoreLabel.text = "Player2: \(player2Score)"
        }
    }
    var maximumScore = 3
    
    var windSpeed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        angleChanged(self)
        velocityChanged(self)
        
        setWindSpeed()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    func setWindSpeed() {
        //   Conversion of windspeed to Metres per second
        let kph = Int.random(in: -50...50)
        windSpeed = Int(Double(kph) / 3.6)
        switch windSpeed {
        case _ where windSpeed < 0:
            windLabel.text = "WIND: Speed: \(abs(kph))kph Direction: Right to Left"
        case _ where windSpeed > 0:
            windLabel.text = "WIND: Speed: \(abs(kph))kph Direction: Left to Right"
        default:
            windLabel.text = "WIND: Calm"
        }    
    }
    
    @IBAction func launch(_ sender: Any) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
        
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value), wind: windSpeed)
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        
        launchButton.isHidden = false
    }
    
    func updateScores(player: Int, playerScore: Int) {
        currentPlayer = player
        if player == 1 {
            player1Score += 1
        } else {
            player2Score += 1
        }
        
        if player1Score == maximumScore || player2Score == maximumScore {
            showAlert("GAME OVER", message: "Player \(currentPlayer) has won!\nPlay Again?", buttonText: "OK")
        }
    }
    
    func showAlert(_ title: String, message: String, buttonText: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: buttonText, style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: buttonText, style: .default, handler: { (action) in
            self.resetGame()
            self.setWindSpeed()
        }))
        present(ac, animated: true)
    }
    
    func resetGame() {
        player1Score = 0
        player2Score = 0
        currentGame?.currentPlayer = 1
        playerNumber.text = "<<< PLAYER ONE"
        angleSlider.value = 45
        velocitySlider.value = 125
        angleChanged(self)
        velocityChanged(self)
    }
    
}
