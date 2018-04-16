//
//  GameScene.swift
//  SpacegameReloaded
//
//  Created by Training on 01/10/2016.
//  Copyright © 2016 Training. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import CoreData
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var managedObjectContext:NSManagedObjectContext!
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    
    var scoreLabel:SKLabelNode!
    var powerUp:SKSpriteNode!
    
    var levelLabelNode: SKLabelNode!
    var gameLevel: Int = 1
    
    var ammoLabel: SKLabelNode!
    var ammoCountLabel: SKLabelNode!
    var ammoCount: Int = 100

    var alienSpeed = 6

    var players = [Player]()
    
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer:Timer!
    var alienTimer:Timer!
    var powerUpTimer:Timer!
    
    var possibleAliens = ["alien", "alien2", "alien3"]
    var possiblePowerUps: [Int:String] = [0:"double",1:"heart"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    let powerUpCategory:UInt32 = 0x1 << 2
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    var livesArray:[SKSpriteNode]!
    
    
    override func didMove(to view: SKView) {
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try self.managedObjectContext.save()
            self.loadData()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
        
        addLives()
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: players[0].spaceship!)
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 20)
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 80, y: self.frame.size.height - 70)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        
        ammoCountLabel = SKLabelNode(text: "\(ammoCount)")
        ammoCountLabel.position = CGPoint(x: self.frame.size.width - 50, y: self.frame.size.height - 100)
        ammoCountLabel.fontName = "AmericanTypewriter-Bold"
        ammoCountLabel.fontSize = 20
        ammoCountLabel.fontColor = UIColor.white
        self.addChild(ammoCountLabel)
        
        ammoLabel = SKLabelNode(text: "Ammo: ")
        ammoLabel.position = CGPoint(x: self.frame.size.width - 110, y: self.frame.size.height - 100)
        ammoLabel.fontName = "AmericanTypewriter-Bold"
        ammoLabel.fontSize = 20
        ammoLabel.fontColor = UIColor.white
        self.addChild(ammoLabel)
        
        levelLabelNode = SKLabelNode(text: "Level \(gameLevel)")
        levelLabelNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (Timer) in
            self.levelLabelNode.isHidden = true
        })
        self.addChild(levelLabelNode)
        
        
        var timeInterval = 0.75
        var ammoTimerIntervall = 0.25
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.4
            ammoTimerIntervall = 0.2
        }
        
        alienTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        powerUpTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(addPowerUp), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(nextLvl), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(withTimeInterval: ammoTimerIntervall, repeats: true, block: { (Timer) in
            if(self.ammoCount < 100){
            self.ammoCount += 1
            self.ammoCountLabel.text = "\(self.ammoCount)"
            }
        })
        

        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    func nextLvl(){
        gameLevel += 1
        levelLabelNode.text = "Level \(gameLevel)"
        levelLabelNode.isHidden = false
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (Timer) in
            self.levelLabelNode.isHidden = true
        })
        
        if(alienSpeed > 2){
        alienSpeed -= 1
        }
        
        if(gameLevel == 6){
            if alienTimer != nil {
                alienTimer.invalidate()
                alienTimer = nil
            }
            
            for i in 0...aliveAlienArray.count - 1 {
                aliveAlienArray[i].removeFromParent()
            }
            
            for i in 0...ingamePowerupsArray.count - 1 {
                ingamePowerupsArray[i].removeFromParent()
            }
            
            let animationDuration:TimeInterval = 5
            
            var actionArray = [SKAction]()
            
            actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
            actionArray.append(SKAction.removeFromParent())
            
            player.run(SKAction.sequence(actionArray))
            
            gameTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: false, block: { (Timer) in
                let transition = SKTransition.flipHorizontal(withDuration: 0.5 )
                let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                self.players[0].score += Int32(self.score)
                gameOver.score = self.score
                gameOver.win = true
                self.view?.presentScene(gameOver, transition: transition)
            })

        }
    }

    func loadData(){
        let playerRequest:NSFetchRequest<Player> = Player.fetchRequest()
        
        do {
            players = try managedObjectContext.fetch(playerRequest)
        } catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
    }
    
    func addLives(){
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: "heart")
            liveNode.position = CGPoint(x: self.frame.size.width - CGFloat(5 - live) * liveNode.size.width, y: self.frame.size.height - 60)
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    
    var selectedPowerup:String = ""

    func addPowerUp() {
        let random = Int(arc4random_uniform(UInt32(possiblePowerUps.count)))
        
        let powerUp = SKSpriteNode(imageNamed: possiblePowerUps[random]!)
        selectedPowerup = possiblePowerUps[random]!

        let randomPowerUpPosition = GKRandomDistribution(lowestValue: 0, highestValue: 360)
        let position = CGFloat(randomPowerUpPosition.nextInt())
        
        powerUp.position = CGPoint(x: position, y: self.frame.size.height + powerUp.size.height)
        
        powerUp.physicsBody = SKPhysicsBody(rectangleOf: powerUp.size)
        powerUp.physicsBody?.isDynamic = true
        
        powerUp.physicsBody?.categoryBitMask = powerUpCategory
        powerUp.physicsBody?.contactTestBitMask = photonTorpedoCategory
        powerUp.physicsBody?.collisionBitMask = 0
        
        self.addChild(powerUp)
        
        ingamePowerupsArray.append(powerUp)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -powerUp.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        powerUp.run(SKAction.sequence(actionArray))
    }
    
    
    var aliveAlienArray: [SKSpriteNode] = []
    var ingamePowerupsArray: [SKSpriteNode] = []
    
    func addAlien () {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 360)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        aliveAlienArray.append(alien)
        
        let animationDuration:TimeInterval = TimeInterval(alienSpeed)
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.run {
            self.run(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
            
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.last
                liveNode!.removeFromParent()
                self.livesArray.removeLast()
                
                if self.livesArray.count == 0 {
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5 )
                    let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    self.players[0].score += Int32(self.score)
                    gameOver.score = self.score
                    self.view?.presentScene(gameOver, transition: transition)
                }
            }
            
        })
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(ammoCount > 0) {
            ammoCount -= 1
            fireTorpedo()
        }
    }
    
    
    var double:Bool = false
    func fireTorpedo() {

        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: players[0].ammo!)
        let torpedoNode2 = SKSpriteNode(imageNamed: players[0].ammo!)

        if(double){
            torpedoNode2.position = player.position
            torpedoNode2.position.y += 50
            torpedoNode2.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
            torpedoNode2.physicsBody?.isDynamic = true
            
            torpedoNode2.physicsBody?.categoryBitMask = photonTorpedoCategory
            torpedoNode2.physicsBody?.contactTestBitMask = alienCategory
            torpedoNode2.physicsBody?.collisionBitMask = 0
            torpedoNode2.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode2)
        }
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration:TimeInterval = 0.3
    
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
        if(double){
            torpedoNode2.run(SKAction.sequence(actionArray))
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
           torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        if(firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & powerUpCategory) == 4 {
            torpedoDidCollideWithPowerUp(torpedoNode: firstBody.node as! SKSpriteNode, powerUpNode: secondBody.node as! SKSpriteNode)
        }
    }
    
    
    func torpedoDidCollideWithAlien (torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {

        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) { 
            explosion.removeFromParent()
        }
        
        score += 5
        
    }



    func torpedoDidCollideWithPowerUp (torpedoNode:SKSpriteNode, powerUpNode:SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "powerUpExplosion")!
        explosion.position = powerUpNode.position
        self.addChild(explosion)
        
        torpedoNode.removeFromParent()
        powerUpNode.removeFromParent()
        
//        self.run(SKAction.playSoundFileNamed("pickup.mp3", waitForCompletion: false))
        if(selectedPowerup == "double"){
        powerUp = SKSpriteNode(imageNamed: "double")
        powerUp.position = CGPoint(x: 40, y: self.frame.size.height - 95)
        self.addChild(powerUp)
        
        double = true
        gameTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false, block: { (Timer) in
            self.powerUp.removeFromParent()
            self.double = false
        self.run(SKAction.playSoundFileNamed("end.mp3", waitForCompletion: false))
        })
        self.run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
    }
        if(selectedPowerup == "heart"){
            let liveNode = SKSpriteNode(imageNamed: "heart")
            if(livesArray.count == 3){
            liveNode.position = CGPoint(x: self.frame.size.width - liveNode.size.width, y: self.frame.size.height - 60)
            } else if(livesArray.count == 2){
            liveNode.position = CGPoint(x: self.frame.size.width - 2 * liveNode.size.width, y: self.frame.size.height - 60)
            } else if(livesArray.count == 1){
            liveNode.position = CGPoint(x: self.frame.size.width - 3 * liveNode.size.width, y: self.frame.size.height - 60)
            } else {
                print("Max Lives!")
            }
            if(livesArray.count < 4 && livesArray.count > 0){
            self.addChild(liveNode)
            livesArray.append(liveNode)
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        } else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
