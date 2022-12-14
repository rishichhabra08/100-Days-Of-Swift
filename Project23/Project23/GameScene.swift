//
//  GameScene.swift
//  Project23
//
//  Created by Rishi Chhabra on 16/08/22.
//

import AVFoundation
import SpriteKit

enum ForceBomb {
    case never,random,always
}


class GameScene: SKScene {
    
    var gameScore : SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var activeEnemies = [SKSpriteNode]()
    
    var liveImages = [SKSpriteNode]()
    
    var lives = 0
    
    var activeSliceBG : SKShapeNode!
    var activeSliceFG : SKShapeNode!
    var bombSound : AVAudioPlayer?
    var isSwooshSoundActive = false
    
    var activeSlicePoints = [CGPoint]()

    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.fontSize = 48
        addChild(gameScore)
        
        score = 0
    }
    
    func createLives() {
        for i in 0..<3 {
            let liveSprite = SKSpriteNode(imageNamed: "sliceLife")
            liveSprite.position = CGPoint(x: CGFloat( 834 + (i*70)), y: 720)
            addChild(liveSprite)
            liveImages.append(liveSprite)
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
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceFG.path = nil
            activeSliceBG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        if !isSwooshSoundActive {
            playSwooshSound()
        }
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let sound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(sound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.3))
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.3))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        activeSliceFG.removeAllActions()
        activeSliceBG.removeAllActions()
        
        activeSliceFG.alpha = 1
        activeSliceBG.alpha = 1
    }
    
    func createEnemy(forceBomb : ForceBomb = .random) {
        
        let enemy : SKSpriteNode
        
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            enemyType = 1
        }
        if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSound != nil {
                bombSound?.stop()
                bombSound = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSound = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
                
            }
            
                
            
            
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        
        let randomXvelocity : Int
        
        if randomPosition.x < 256 {
            randomXvelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXvelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            randomXvelocity = -Int.random(in: 3...5)
        } else {
            randomXvelocity = -Int.random(in: 8...15)
        }
        
        let randomYvelocity = Int.random(in: 24...32)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXvelocity * 40, dy: randomYvelocity * 40)
        enemy.physicsBody?.angularVelocity = CGFloat.random(in: -3...3)
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            bombSound?.stop()
            bombSound = nil
        }
    }
    
}
