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
    
    
    //Load ship from Core Data by Name
//    func loadShip(){
//        Constants.spaceship = LocalDatabase.sharedInstance.getSpaceshipbyName(name: Constants.currentPlayer.shipname)
//    }
//
    override func didMove(to view: SKView) {
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try self.managedObjectContext.save()
            self.loadData()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
        
//        loadShip()

        starfield = self.childNode(withName: "starfield") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "button_spiel-starten") as? SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "button_spiel-starten")
        
        shopButtonNode = self.childNode(withName: "button_spaceshop") as? SKSpriteNode
        shopButtonNode.texture = SKTexture(imageNamed: "button_spaceshop")
        
        difficultyButtonNode = self.childNode(withName: "button_schwierigkeit") as? SKSpriteNode
        difficultyButtonNode.texture = SKTexture(imageNamed: "button_schwierigkeit")
        
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as? SKLabelNode
        
        scoreLabelNode = self.childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabelNode.text = String(Constants.players[0].score)
        
        levelLabelNode = self.childNode(withName: "levelLabel") as? SKLabelNode
        levelLabelNode.text = String(Constants.players[0].level)
        
        resetButtonNode = self.childNode(withName: "button_reset-game") as? SKSpriteNode
        resetButtonNode.texture = SKTexture(imageNamed: "button_reset-game")
        
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
            
            if nodesArray.first?.name == "button_spiel-starten" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "button_schwierigkeit" {
                changeDifficulty()
            } else if nodesArray.first?.name == "button_reset-game" {
                setUp()
            } else if nodesArray.first?.name == "button_spaceshop" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let shopScene = SKScene(fileNamed: "ShopScene") as! ShopScene
                self.view?.presentScene(shopScene, transition: transition)
            }
        }
    }
    
    func setUp(){
        LocalDatabase.sharedInstance.dropTable()
        Constants.spaceship = Constants.spaceships.first
        Constants.players[0].score = 0
        scoreLabelNode.text = String(Constants.players[0].score)
        Constants.players[0].level = 1
        levelLabelNode.text = String(Constants.players[0].level)
        Constants.players[0].ammo = "torpedo"
        Constants.players[0].spaceship = "shuttle"
        Constants.players[0].shipname = "Shuttle"

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
