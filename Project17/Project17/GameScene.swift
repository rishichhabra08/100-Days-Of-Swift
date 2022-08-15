//
//  GameScene.swift
//  Project17
//
//  Created by Rishi Chhabra on 15/08/22.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield : SKEmitterNode!
    var scoreLabel : SKLabelNode!
    var player : SKSpriteNode!
    
    var possibleEnemies = ["ball","hammer","tv"]
    var gameTimer : Timer?
    var isGameOver = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    override func didMove(to view: SKView) {
        
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.zPosition = -1
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        
        player = SKSpriteNode(imageNamed: "player")
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody?.contactTestBitMask = 1
        player.name = "player"
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func createEnemy() {

        guard let enemy = possibleEnemies.randomElement() else {return}
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    override func update(_ currentTime: TimeInterval) {
        
        
        
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score+=1
        }
    }
    
    
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else {return}
        
        
        switch key.keyCode {
        case .keyboardW:
            print("W")
            player.position = CGPoint(x: player.position.x, y: player.position.y+1)
            if player.position.y < 100 {
                player.position.y = 100
            } else if  player.position.y > 668 {
                player.position.y = 668
            }
            
            
        case .keyboardS:
            print("S")
            player.position = CGPoint(x: player.position.x, y: player.position.y-1)
            if player.position.y < 100 {
                player.position.y = 100
            } else if  player.position.y > 668 {
                player.position.y = 668
            }
        default:
            super.pressesBegan(presses, with: event)
        }
        
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        
    }
    
}
