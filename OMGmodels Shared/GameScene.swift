//
//  GameScene.swift
//  OMGmodels Shared
//
//  Created by Emanuil Vartanyan on 3/18/23.
//

import SpriteKit
import CoreMotion

class Ball: SKSpriteNode {}

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?
    var motionManager : CMMotionManager?
    
    let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    var matchedBalls = Set<Ball>()
    
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "SCORE: \(formattedScore)"
        }
    }
    var balls = ["ballBlue", "ballGreen", "ballPurple", "ballRed", "ballYellow"]

    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .resizeFill
        
        return scene
    }
    
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        scoreLabel.fontSize = 72
        scoreLabel.position = CGPoint(x: 20, y: 20)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        let ball = SKSpriteNode(imageNamed: "ballBlue")
        let ballRadius = ball.frame.width / 2.0
        
        for i in stride(from: ballRadius, to: view.bounds.width - ballRadius, by: ball.frame.width) {
            for j in stride(from: 100, to: view.bounds.height - ballRadius, by: ball.frame.height) {
                let ballType = balls.randomElement()!
                let ball = Ball(imageNamed: ballType)
                ball.position = CGPoint(x: i, y: j)
                ball.name = ballType
                
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.restitution = 0
                ball.physicsBody?.friction = 0
                addChild(ball)
            }
        }
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)))
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
    }

    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    }
    
    func getMatches(from node: Ball) {
        for body in node.physicsBody!.allContactedBodies() {
            guard let ball = body.node as? Ball else {continue}
            guard ball.name == node.name else {continue}
            
            if !matchedBalls.contains(ball) {
                matchedBalls.insert(ball)
                getMatches(from: ball)
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let position = touches.first?.location(in: self) else {return}
        guard let tappedBall = nodes(at: position).first(where: { $0 is Ball}) as? Ball else {return}
        
        matchedBalls.removeAll(keepingCapacity: true)
        
        getMatches(from: tappedBall)
        
        if matchedBalls.count >= 3 {
            
            score += Int(pow(2, Double(min(matchedBalls.count, 16))))
            for ball in matchedBalls {
                ball.removeFromParent()
            }
        }
    }
}


