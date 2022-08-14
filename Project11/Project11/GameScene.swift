//
//  GameScene.swift
//  Project11
//
//  Created by Rishi Chhabra on 13/08/22.
//

import SpriteKit


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel : SKLabelNode!
    
    var editMode : Bool = false {
        didSet {
            if editMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
       let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background )
        
        scoreLabel = SKLabelNode(fontNamed: "chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "chalkduster")
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        physicsWorld.contactDelegate = self
        
        
        
        makeSlot(atPosition: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(atPosition: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(atPosition: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(atPosition: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(atPoint: CGPoint(x: 0, y: 0))
        makeBouncer(atPoint: CGPoint(x: 256, y: 0))
        makeBouncer(atPoint: CGPoint(x: 512, y: 0))
        makeBouncer(atPoint: CGPoint(x: 768, y: 0))
        makeBouncer(atPoint: CGPoint(x: 1024, y: 0))
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editMode.toggle()
        }
        else {
            if (editMode)
            {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
                
            } else {
                
                //        let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))
                //        box.position = location
                //        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
                //        addChild(box)
                
                let ball = SKSpriteNode(imageNamed: "ballRed")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.6
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = location
                ball.name = "ball"
                addChild(ball)
            }
            
            
        }
        
        
        
    }
    
    func makeBouncer(atPoint: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.position = atPoint
        bouncer.physicsBody?.isDynamic = false
        bouncer.name = "bouncer"
        addChild(bouncer)
    }
    
    func makeSlot(atPosition : CGPoint, isGood: Bool) {
        
        let slotBase : SKSpriteNode
        let slotGlow : SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        slotGlow.physicsBody?.isDynamic = false
        
        slotBase.position = atPosition
        slotGlow.position = atPosition
        addChild(slotGlow)
        addChild(slotBase)
        
        
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        
        if object.name == "good" {
            destroy(ball)
            score+=1
        }
        if object.name == "bad" {
            destroy(ball)
            score-=1
        }
    }
    
    func destroy(_ ball: SKNode) {
        
        if let particles = SKEmitterNode(fileNamed: "FireParticles") {
            particles.position = ball.position
            addChild(particles)
        }
            
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if contact.bodyB.node?.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
    
}
