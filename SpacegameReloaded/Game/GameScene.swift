//
//  GameScene.swift
//  Spacegame
//
//  Created by Hussein Souleiman on 10/04/2018.
//  Copyright © 2018 Hussein Souleiman. All rights reserved.
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
    var levelNumberNode: SKLabelNode!
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
    //    var powerUpTimer:Timer!
    var bossTorpedoTimer:Timer!
    var nextLevelTimer:Timer!
    
    var possibleAliens = ["alien", "alien2", "alien3"]
    
    var possiblePowerUps: [Int:String] = [0:"double",1:"heart"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    let powerUpCategory:UInt32 = 0x1 << 2
    let playerCategory:UInt32 = 0x1 << 3
    let bossTorpedoCategory:UInt32 = 0x1 << 4
    
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    var livesArray:[SKSpriteNode]!
    
    func killAlTimer(){
        if(gameTimer != nil){
            gameTimer.invalidate()
            gameTimer = nil
        }
        if(alienTimer != nil) {
            alienTimer.invalidate()
            alienTimer = nil
        }
        //        if(powerUpTimer != nil) {
        //
        //            powerUpTimer.invalidate()
        //            powerUpTimer = nil
        //        }
        if(bossTorpedoTimer != nil) {
            bossTorpedoTimer.invalidate()
            bossTorpedoTimer = nil
        }
        if(nextLevelTimer != nil) {
            nextLevelTimer.invalidate()
            nextLevelTimer = nil
        }
    }
    
    
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
        starfield.position = CGPoint(x: 0, y: 812)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        let spaceship = Constants.currentPlayer.spaceship!
        player = SKSpriteNode(imageNamed: spaceship)
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
        
        levelNumberNode = SKLabelNode(text: "\(gameLevel)")
        levelNumberNode.position = CGPoint(x: self.frame.size.width - 50, y: self.frame.size.height - 130)
        levelNumberNode.fontName = "AmericanTypewriter-Bold"
        levelNumberNode.fontSize = 28
        levelNumberNode.fontColor = UIColor.white
        self.addChild(levelNumberNode)
        
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
        //        powerUpTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(addPowerUp), userInfo: nil, repeats: true)
        nextLevelTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(nextLevel), userInfo: nil, repeats: true)
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
    
    @objc func nextLevel(){
        if(gameLevel < 5){
            gameLevel += 1
            levelNumberNode.text = String(gameLevel)
            levelLabelNode.text = "Level \(gameLevel)"
            levelLabelNode.isHidden = false
        } else {
            gameLevel += 1
            levelNumberNode.text = String(gameLevel)
            levelLabelNode.text = "Boss"
            levelLabelNode.isHidden = false
        }
        
        
        self.run(SKAction.wait(forDuration: 3)){
            self.levelLabelNode.isHidden = true
        }
        
        if(alienSpeed > 2){
            alienSpeed -= 1
        }
        
        
        if(gameLevel == 6){
            if alienTimer != nil {
                alienTimer.invalidate()
                alienTimer = nil
            }
            if nextLevelTimer != nil {
                nextLevelTimer.invalidate()
                nextLevelTimer = nil
            }
            
            for i in 0...aliveAlienArray.count - 1 {
                aliveAlienArray[i].removeFromParent()
            }
            
            let animationDuration:TimeInterval = 5
            
            var actionArray = [SKAction]()
            
            actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
            actionArray.append(SKAction.removeFromParent())
            
            player.run(SKAction.sequence(actionArray))
            
            gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(bossMode), userInfo: nil, repeats: false)
        }
    }
    
    @objc func bossMode(){
        self.view?.isUserInteractionEnabled = false
        self.run(SKAction.wait(forDuration: 6)){
            self.view?.isUserInteractionEnabled = true
        }
        addPlayer()
        addBoss()
        
        
    }
    
    func addPlayer(){
        player.removeFromParent()
        
        player = SKSpriteNode(imageNamed: self.players[0].spaceship!)
        player.position = CGPoint(x: self.frame.size.width / 2, y: self.player.size.height / 2 - 20)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = bossTorpedoCategory
        player.physicsBody?.collisionBitMask = 0
        addChild(self.player)
        
        let animationDuration:TimeInterval = 2
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: self.frame.size.width / 2, y: self.player.size.height / 2 + 20), duration: animationDuration))
        
        player.run(SKAction.sequence(actionArray))
    }
    
    
    func addBoss(){
        bossAlive = true
        let alienboss = SKSpriteNode(imageNamed: "firstBoss")
        
        alienboss.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height + 100)
        alienboss.physicsBody = SKPhysicsBody(rectangleOf: alienboss.size)
        alienboss.physicsBody?.isDynamic = true
        
        alienboss.physicsBody?.categoryBitMask = alienCategory
        alienboss.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alienboss.physicsBody?.collisionBitMask = 0
        
        self.addChild(alienboss)
        
        let animationDuration:TimeInterval = 5
        
        var actionArray = [SKAction]()
        var rightleftArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 150), duration: animationDuration))
        rightleftArray.append(SKAction.move(to: CGPoint(x: 25, y: self.frame.size.height - 150), duration: 3))
        rightleftArray.append(SKAction.move(to: CGPoint(x: self.frame.size.width+100, y: self.frame.size.height - 150), duration: 3))
        
        alienboss.run(SKAction.sequence(actionArray))
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (Timer) in
            alienboss.run(SKAction.sequence(rightleftArray))
        })
        
        self.run(SKAction.wait(forDuration: 5)){
            self.fireBossTopedos(alienboss: alienboss)
        }
    }
    
    var bossTorpedoArray: [SKSpriteNode] = []
    
    func fireBossTopedos(alienboss: SKSpriteNode){
        bossTorpedoTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (Timer) in
            let bossTorpedoNode = SKSpriteNode(imageNamed: "bossammo1")
            
            bossTorpedoNode.position = alienboss.position
            bossTorpedoNode.position.y -= 5
            bossTorpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: bossTorpedoNode.size.width / 2)
            bossTorpedoNode.physicsBody?.isDynamic = true
            
            bossTorpedoNode.physicsBody?.categoryBitMask = self.bossTorpedoCategory
            bossTorpedoNode.physicsBody?.contactTestBitMask = self.playerCategory
            bossTorpedoNode.physicsBody?.collisionBitMask = 0
            bossTorpedoNode.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(bossTorpedoNode)
            self.bossTorpedoArray.append(bossTorpedoNode)
            
            var actionArrayTorpedoBoss = [SKAction]()
            
            actionArrayTorpedoBoss.append(SKAction.move(to: CGPoint(x: alienboss.position.x, y: -10), duration: 2))
            actionArrayTorpedoBoss.append(SKAction.removeFromParent())
            
            bossTorpedoNode.run(SKAction.sequence(actionArrayTorpedoBoss))
        })
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
    
    @objc func addPowerUp() {
        var random = Int(arc4random_uniform(UInt32(possiblePowerUps.count)))
        if(livesArray.count == 4) {
            random = 0
        }
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
        
        //let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -powerUp.size.height), duration: TimeInterval(alienSpeed)))
        actionArray.append(SKAction.removeFromParent())
        powerUp.run(SKAction.sequence(actionArray))
    }
    
    
    var aliveAlienArray: [SKSpriteNode] = []
    var ingamePowerupsArray: [SKSpriteNode] = []
    
    func loseLife() {
        self.run(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        
        if self.livesArray.count > 0 {
            let liveNode = self.livesArray.last
            liveNode!.removeFromParent()
            self.livesArray.removeLast()
            
            
            if self.livesArray.count == 0 {
                self.run(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
                self.player.removeFromParent()
                gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5 )
                    let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    self.players[0].score += Int32(self.score)
                    gameOver.score = self.score
                    self.killAlTimer()
                    self.view?.presentScene(gameOver, transition: transition)
                })
                
            }
        }
    }
    
    @objc func addAlien () {
        let alienOrPowerUP = Int.random(in: 0...100)
        
        if(alienOrPowerUP <= 2){
            addPowerUp()
        } else {
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
                
                self.loseLife()
                
            })
            actionArray.append(SKAction.removeFromParent())
            
            alien.run(SKAction.sequence(actionArray))
        }
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
        
        let torpedoNode1 = SKSpriteNode(imageNamed: Constants.currentPlayer.ammo!)
        let torpedoNode2 = SKSpriteNode(imageNamed: Constants.currentPlayer.ammo!)
        let torpedoNode3 = SKSpriteNode(imageNamed: Constants.currentPlayer.ammo!)
        let torpedoNode4 = SKSpriteNode(imageNamed: Constants.currentPlayer.ammo!)
        let torpedoNode5 = SKSpriteNode(imageNamed: Constants.currentPlayer.ammo!)

        var torpedoArray:[SKSpriteNode] = []
   
        switch Constants.currentPlayer.ammo! {
        case "ammo9.png":
            let animationDuration:TimeInterval = 0.3
            if(double) {

                torpedoNode2.position = player.position
                torpedoNode2.position.y += 5
                torpedoNode2.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode2.size.width / 2)
                torpedoNode2.physicsBody?.isDynamic = true
                torpedoNode2.physicsBody?.categoryBitMask = photonTorpedoCategory
                torpedoNode2.physicsBody?.contactTestBitMask = alienCategory
                torpedoNode2.physicsBody?.contactTestBitMask = bossTorpedoCategory
                torpedoNode2.physicsBody?.collisionBitMask = 0
                torpedoNode2.physicsBody?.usesPreciseCollisionDetection = true
                
                self.addChild(torpedoNode2)
            }
            
            torpedoNode1.position = player.position
            torpedoNode1.position.y += 5
            torpedoNode1.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode1.size.width / 2)
            torpedoNode1.physicsBody?.isDynamic = true
            torpedoNode1.physicsBody?.categoryBitMask = photonTorpedoCategory
            torpedoNode1.physicsBody?.contactTestBitMask = alienCategory
            torpedoNode1.physicsBody?.contactTestBitMask = bossTorpedoCategory
            torpedoNode1.physicsBody?.collisionBitMask = 0
            torpedoNode1.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode1)
            
            var actionArray1 = [SKAction]()
            var actionArray2 = [SKAction]()
            
            if double {
                actionArray1.append(SKAction.move(to: CGPoint(x: player.position.x + 30, y: self.frame.size.height + 10), duration: animationDuration))
                actionArray1.append(SKAction.removeFromParent())
                torpedoNode1.run(SKAction.sequence(actionArray1))
                actionArray2.append(SKAction.move(to: CGPoint(x: player.position.x - 30, y: self.frame.size.height + 10), duration: animationDuration))
                actionArray2.append(SKAction.removeFromParent())
                torpedoNode2.run(SKAction.sequence(actionArray2))
            } else {
                actionArray1.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
                actionArray1.append(SKAction.removeFromParent())
                torpedoNode1.run(SKAction.sequence(actionArray1))
            }
            break
        case "ammo7.png":
            if(double){
                torpedoNode4.position = player.position
                torpedoNode4.position.y += 5
                torpedoNode4.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode4.size.width / 2)
                torpedoNode4.physicsBody?.isDynamic = true
                torpedoNode4.physicsBody?.categoryBitMask = photonTorpedoCategory
                torpedoNode4.physicsBody?.contactTestBitMask = alienCategory
                torpedoNode4.physicsBody?.contactTestBitMask = bossTorpedoCategory
                torpedoNode4.physicsBody?.collisionBitMask = 0
                torpedoNode4.physicsBody?.usesPreciseCollisionDetection = true
                
                self.addChild(torpedoNode4)
                
                torpedoNode5.position = player.position
                torpedoNode5.position.y += 5
                torpedoNode5.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode5.size.width / 2)
                torpedoNode5.physicsBody?.isDynamic = true
                torpedoNode5.physicsBody?.categoryBitMask = photonTorpedoCategory
                torpedoNode5.physicsBody?.contactTestBitMask = alienCategory
                torpedoNode5.physicsBody?.contactTestBitMask = bossTorpedoCategory
                torpedoNode5.physicsBody?.collisionBitMask = 0
                torpedoNode5.physicsBody?.usesPreciseCollisionDetection = true
                
                self.addChild(torpedoNode5)
            }
            torpedoNode1.position = player.position
            torpedoNode1.position.y += 5
            torpedoNode1.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode1.size.width / 2)
            torpedoNode1.physicsBody?.isDynamic = true
            torpedoNode1.physicsBody?.categoryBitMask = photonTorpedoCategory
            torpedoNode1.physicsBody?.contactTestBitMask = alienCategory
            torpedoNode1.physicsBody?.contactTestBitMask = bossTorpedoCategory
            torpedoNode1.physicsBody?.collisionBitMask = 0
            torpedoNode1.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode1)

            torpedoNode2.position = player.position
            torpedoNode2.position.y += 5
            torpedoNode2.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode2.size.width / 2)
            torpedoNode2.physicsBody?.isDynamic = true
            torpedoNode2.physicsBody?.categoryBitMask = photonTorpedoCategory
            torpedoNode2.physicsBody?.contactTestBitMask = alienCategory
            torpedoNode2.physicsBody?.contactTestBitMask = bossTorpedoCategory
            torpedoNode2.physicsBody?.collisionBitMask = 0
            torpedoNode2.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode2)

            torpedoNode3.position = player.position
            torpedoNode3.position.y += 5
            torpedoNode3.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode3.size.width / 2)
            torpedoNode3.physicsBody?.isDynamic = true
            torpedoNode3.physicsBody?.categoryBitMask = photonTorpedoCategory
            torpedoNode3.physicsBody?.contactTestBitMask = alienCategory
            torpedoNode3.physicsBody?.contactTestBitMask = bossTorpedoCategory
            torpedoNode3.physicsBody?.collisionBitMask = 0
            torpedoNode3.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode3)
            
//            let animationDuration:TimeInterval = 1
            
            var actionArray1 = [SKAction]()
            var actionArray2 = [SKAction]()
            var actionArray3 = [SKAction]()
            var actionArray4 = [SKAction]()
            var actionArray5 = [SKAction]()

            //I.was stimmt immernoch nicht mit dem 7er
            
            actionArray1.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: 1))
            actionArray1.append(SKAction.removeFromParent())

            actionArray2.append(SKAction.move(to: CGPoint(x: player.position.x + 75, y: self.frame.size.height + 10), duration: 1))
            actionArray2.append(SKAction.removeFromParent())
            
            actionArray3.append(SKAction.move(to: CGPoint(x: player.position.x - 75, y: self.frame.size.height + 10), duration: 1))
            actionArray3.append(SKAction.removeFromParent())
            
            actionArray4.append(SKAction.move(to: CGPoint(x: player.position.x + 150, y: self.frame.size.height + 10), duration: 1))
            actionArray4.append(SKAction.removeFromParent())
            
            actionArray5.append(SKAction.move(to: CGPoint(x: player.position.x - 150, y: self.frame.size.height + 10), duration: 1))
            actionArray5.append(SKAction.removeFromParent())
            
            torpedoNode1.run(SKAction.sequence(actionArray1))
            torpedoNode2.run(SKAction.sequence(actionArray2))
            torpedoNode3.run(SKAction.sequence(actionArray3))
            torpedoNode4.run(SKAction.sequence(actionArray4))
            torpedoNode5.run(SKAction.sequence(actionArray5))

            break
        default:
            if(double){
                torpedoNode2.position = player.position
                torpedoNode2.position.y += 70
                torpedoNode2.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode1.size.width / 2)
                torpedoNode2.physicsBody?.isDynamic = true
                
                torpedoNode2.physicsBody?.categoryBitMask = photonTorpedoCategory
                torpedoNode2.physicsBody?.contactTestBitMask = alienCategory
                torpedoNode2.physicsBody?.collisionBitMask = 0
                torpedoNode2.physicsBody?.usesPreciseCollisionDetection = true
                
                self.addChild(torpedoNode2)
            }
            torpedoNode1.position = player.position
            torpedoNode1.position.y += 5
            torpedoNode1.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode1.size.width / 2)
            torpedoNode1.physicsBody?.isDynamic = true
            
            torpedoNode1.physicsBody?.categoryBitMask = photonTorpedoCategory
            torpedoNode1.physicsBody?.contactTestBitMask = alienCategory
            torpedoNode1.physicsBody?.contactTestBitMask = bossTorpedoCategory
            torpedoNode1.physicsBody?.collisionBitMask = 0
            torpedoNode1.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode1)
            
                    let animationDuration:TimeInterval = 0.3
            
                    var actionArray = [SKAction]()
            
                    actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
                    actionArray.append(SKAction.removeFromParent())
            
                    torpedoNode1.run(SKAction.sequence(actionArray))
                    if(double){
                        torpedoNode2.run(SKAction.sequence(actionArray))
                    }

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
        
        var toKillArray : [SKSpriteNode] = []
        var torpedosToKill : [SKSpriteNode] = []
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
            if(Constants.spaceship!.laser) {
                if(secondBody.node != nil) {
                    toKillArray.append(secondBody.node as! SKSpriteNode)
                    torpedoDidCollideWithAlien(tokillArray: toKillArray)
                } else {
                    torpedoDidCollideWithAlien(torpedoNode: firstBody.node as? SKSpriteNode)
                }
            } else {
                toKillArray.append(secondBody.node as! SKSpriteNode)
                torpedoDidCollideWithAlien(torpedoNode: firstBody.node as? SKSpriteNode, tokillArray: toKillArray)
            }
        }
        
        if(firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & powerUpCategory) == 4 {
            torpedoDidCollideWithPowerUp(torpedoNode: firstBody.node as! SKSpriteNode, powerUpNode: secondBody.node as! SKSpriteNode)
        }
        if(firstBody.categoryBitMask & playerCategory) != 0 && (secondBody.categoryBitMask & bossTorpedoCategory) == 16 {
            bossTorpedoDidCollideWithPlayer(playerNode: firstBody.node as! SKSpriteNode, torpedoNode: secondBody.node as! SKSpriteNode)
        }
        if(firstBody.categoryBitMask & photonTorpedoCategory) == 1 && (secondBody.categoryBitMask & bossTorpedoCategory) == 16 {
            if(Constants.spaceship!.laser){
                if(secondBody.node != nil) {
                    torpedosToKill.append(secondBody.node as! SKSpriteNode)
                    torpedoDidCollideWithTorpedo(toKillArray: torpedosToKill)
                } else {
                    torpedoDidCollideWithTorpedo(torpedoNode: firstBody.node as? SKSpriteNode)
                }
            } else {
                torpedosToKill.append(secondBody.node as! SKSpriteNode)
                torpedoDidCollideWithTorpedo(torpedoNode: firstBody.node as? SKSpriteNode, toKillArray: torpedosToKill)
            }
        }
    }
    
    func bossTorpedoDidCollideWithPlayer(playerNode:SKSpriteNode, torpedoNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = playerNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        loseLife()
    }
    
    func torpedoDidCollideWithTorpedo(torpedoNode:SKSpriteNode? = nil , toKillArray:[SKSpriteNode]? = nil) {
        
        torpedoNode?.removeFromParent()
        
        for node in toKillArray! {
            let explosion = SKEmitterNode(fileNamed: "selectItem")!
            explosion.position = node.position
            self.addChild(explosion)
            node.removeFromParent()
            self.run(SKAction.wait(forDuration: 1)) {
                explosion.removeFromParent()
            }
        }
        
        
        
    }
    
    var bossAlive = false
    var bosslifes = 3
    func torpedoDidCollideWithAlien(torpedoNode:SKSpriteNode? = nil, tokillArray:[SKSpriteNode]? = nil) {
        
        if bossAlive==true {
            if bosslifes > 1 {
                torpedoNode?.removeFromParent()
                for node in tokillArray! {
                    let explosion = SKEmitterNode(fileNamed: "bossExplosion")!
                    explosion.position = node.position
                    self.addChild(explosion)
                    
                    self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
                    
                    let positiondeadBoss = node.position
                    let bosskid = SKSpriteNode(imageNamed: "alien2")
                    bosskid.position = positiondeadBoss
                    self.addChild(bosskid)
                    
                    node.removeFromParent()
                    isUserInteractionEnabled = false
                    
                    self.run(SKAction.wait(forDuration: 2)) {
                        explosion.removeFromParent()
                        self.addBoss()
                    }
                }
                
                
                bosslifes -= 1
                
                
                self.run(SKAction.wait(forDuration: 7)) {
                    self.isUserInteractionEnabled = true
                }
            } else {
                torpedoNode?.removeFromParent()
                
                for node in tokillArray! {
                    let explosion = SKEmitterNode(fileNamed: "Explosion")!
                    explosion.position = node.position
                    self.addChild(explosion)
                    self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
                    node.removeFromParent()
                    self.run(SKAction.wait(forDuration: 2)) {
                        explosion.removeFromParent()
                    }
                }
                
                
                if bossTorpedoTimer != nil {
                    bossTorpedoTimer.invalidate()
                    bossTorpedoTimer = nil
                }
                for i in 0...bossTorpedoArray.count - 1 {
                    bossTorpedoArray[i].removeFromParent()
                }
                score += 100000
                bosslifes = 0
                bossAlive = false
                
                let animationDuration:TimeInterval = 5
                
                var actionArray = [SKAction]()
                
                actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
                actionArray.append(SKAction.removeFromParent())
                
                player.run(SKAction.sequence(actionArray))
                
                self.run(SKAction.wait(forDuration: 6)){
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5 )
                    let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    self.players[0].score += Int32(self.score)
                    gameOver.score = self.score
                    gameOver.win = true
                    self.killAlTimer()
                    self.view?.presentScene(gameOver, transition: transition)
                }
            }
        } else {
            torpedoNode?.removeFromParent()
            for node in tokillArray! {
                let explosion = SKEmitterNode(fileNamed: "Explosion")!
                explosion.position = node.position
                self.addChild(explosion)
                self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
                node.removeFromParent()
                self.run(SKAction.wait(forDuration: 2)) {
                    explosion.removeFromParent()
                }
                score += 100
            }
        }
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
