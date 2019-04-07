//
//  MenuScene.swift
//  SpacegameReloaded
//
//  Created by Hussein Souleiman on 10.04.18.
//  Copyright © 2018 Training. All rights reserved.
//

import SpriteKit
import CoreData

class MenuScene: SKScene {
    
    
    var managedObjectContext:NSManagedObjectContext!
    
    var starfield: SKEmitterNode!
    
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    var scoreLabelNode:SKLabelNode!
    var resetButtonNode:SKSpriteNode!
    var shopButtonNode:SKSpriteNode!
    var levelLabelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try self.managedObjectContext.save()
            self.loadData()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
        
//        create new Player
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//
//        let entity = NSEntityDescription.entity(forEntityName: "Player", in: context)
//        let newUser = NSManagedObject(entity: entity!, insertInto: context)
//
//        newUser.setValue("torpedo", forKey: "ammo")
//        newUser.setValue("shuttle", forKey: "spaceship")
//        newUser.setValue(1, forKey: "level")
//        newUser.setValue(0, forKey: "score")
//
//        Constants.players.append(newUser as! Player)

        
        starfield = self.childNode(withName: "starfield") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as? SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "newGameButton")
        
        shopButtonNode = self.childNode(withName: "shopButton") as? SKSpriteNode
        shopButtonNode.texture = SKTexture(imageNamed: "shopButton")
        
        difficultyButtonNode = self.childNode(withName: "difficultyButton") as? SKSpriteNode
        difficultyButtonNode.texture = SKTexture(imageNamed: "difficultyButton")
        
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as? SKLabelNode
        
        scoreLabelNode = self.childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabelNode.text = String(Constants.players[0].score)
        
        levelLabelNode = self.childNode(withName: "levelLabel") as? SKLabelNode
        levelLabelNode.text = String(Constants.players[0].level)
        
        resetButtonNode = self.childNode(withName: "resetButton") as? SKSpriteNode
        resetButtonNode.texture = SKTexture(imageNamed: "resetButton")
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hard") {
            difficultyLabelNode.text = "Hard"
        } else {
            difficultyLabelNode.text = "Easy"
        }
        
        if Constants.players[0].level == 0 {
            setUp()
        }
        
        if Constants.spaceship == nil {
            Constants.spaceship = Constants.spaceships.first
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "difficultyButton" {
                changeDifficulty()
            } else if nodesArray.first?.name == "resetButton" {
                setUp()
            } else if nodesArray.first?.name == "shopButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let shopScene = SKScene(fileNamed: "ShopScene") as! ShopScene
                self.view?.presentScene(shopScene, transition: transition)
            }
        }
    }
    
    func setUp(){
        Constants.spaceship = Constants.spaceships.first
        Constants.players[0].score = 0
        scoreLabelNode.text = String(Constants.players[0].score)
        Constants.players[0].level = 1
        levelLabelNode.text = String(Constants.players[0].level)
        Constants.players[0].ammo = "torpedo"
        Constants.players[0].spaceship = "shuttle"
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
    }

    func changeDifficulty(){
        let userDefaults = UserDefaults.standard
        
        if difficultyLabelNode.text == "Easy" {
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
        } else {
            difficultyLabelNode.text = "Easy"
            userDefaults.set(false, forKey: "hard")
        }
        
        userDefaults.synchronize()
    }
    
    func loadData(){
        let playerRequest:NSFetchRequest<Player> = Player.fetchRequest()
        
        do {
            Constants.players = try managedObjectContext.fetch(playerRequest)
        } catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
    }
}
