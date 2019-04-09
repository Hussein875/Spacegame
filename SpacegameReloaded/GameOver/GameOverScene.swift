//
//  GameOverScene.swift
//  SpacegameReloaded
//
//  Created by Hussein Souleiman on 10.04.18.
//  Copyright © 2018 Training. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData

class GameOverScene: SKScene {
    
    var players = [Player]()
    var managedObjectContext:NSManagedObjectContext!
    var score:Int = 0
    
    var starfield: SKEmitterNode!

    var gameResultLabelNode:SKLabelNode!
    var scoreLabelNode:SKLabelNode!
    var newGameButtonNode:SKSpriteNode!
    var backToMenuButtonNode:SKSpriteNode!
    
    var win:Bool = false
    
    override func didMove(to view: SKView) {
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try self.managedObjectContext.save()
            self.loadData()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
        
        gameResultLabelNode = self.childNode(withName: "gameResultLabel") as? SKLabelNode
        if(win){
            gameResultLabelNode.text = "YOU WIN"
        } else {
            gameResultLabelNode.text = "GAME OVER"

        }
        
        starfield = self.childNode(withName: "starfield") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        scoreLabelNode = self.childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabelNode.text = "\(score)"
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as? SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "newGameButton")
        
        backToMenuButtonNode = self.childNode(withName: "backToMenuButton") as? SKSpriteNode
        backToMenuButtonNode.texture = SKTexture(imageNamed: "startmenuButton")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let node = self.nodes(at: location)
            
            if node[0].name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view!.presentScene(gameScene, transition: transition)
            } else if node[0].name == "backToMenuButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene
                self.view?.presentScene(menuScene, transition: transition)
            }
        }
    }
    
    func loadData(){
        let scoreRequest:NSFetchRequest<Player> = Player.fetchRequest()
        
        do {
            players = try managedObjectContext.fetch(scoreRequest)
        } catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
    }

}
