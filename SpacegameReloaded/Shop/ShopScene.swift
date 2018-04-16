//
//  ShopScene.swift
//  SpacegameReloaded
//
//  Created by Hussein Souleiman on 12.04.18.
//  Copyright © 2018 Training. All rights reserved.
//
import UIKit
import SpriteKit
import CoreData

class ShopScene: SKScene {
    
    var players = [Player]()
    var managedObjectContext:NSManagedObjectContext!
    
    var backToMenuButtonNode:SKSpriteNode!
    
    var ship1Node:SKSpriteNode!
    var ship2Node:SKSpriteNode!
    var ship3Node:SKSpriteNode!

    var ammo1Node:SKSpriteNode!
    var ammo2Node:SKSpriteNode!
    var ammo3Node:SKSpriteNode!
    
    var selectedShipNode:SKSpriteNode!
    var selectedAmmoNode:SKSpriteNode!
    
//    var dollarNode1:SKSpriteNode!
//    var dollarNode2:SKSpriteNode!
//    var dollarNode3:SKSpriteNode!
//    var dollarNode4:SKSpriteNode!
//    var dollarNode5:SKSpriteNode!
//    var dollarNode6:SKSpriteNode!

    var cashLabelNode:SKLabelNode!

    var starfield: SKEmitterNode!
    
    override func didMove(to view: SKView) {
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try self.managedObjectContext.save()
            self.loadData()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        backToMenuButtonNode = self.childNode(withName: "backToMenuButton") as! SKSpriteNode
        backToMenuButtonNode.texture = SKTexture(imageNamed: "startmenuButton")
        
        ship1Node = self.childNode(withName: "ship1") as! SKSpriteNode
        ship2Node = self.childNode(withName: "ship2") as! SKSpriteNode
        ship3Node = self.childNode(withName: "ship3") as! SKSpriteNode
        ammo1Node = self.childNode(withName: "ammo1") as! SKSpriteNode
        ammo2Node = self.childNode(withName: "ammo2") as! SKSpriteNode
        ammo3Node = self.childNode(withName: "ammo3") as! SKSpriteNode
        
//        dollarNode1 = self.childNode(withName: "dollar1") as! SKSpriteNode
//        dollarNode2 = self.childNode(withName: "dollar2") as! SKSpriteNode
//        dollarNode3 = self.childNode(withName: "dollar3") as! SKSpriteNode
//        dollarNode4 = self.childNode(withName: "dollar4") as! SKSpriteNode
//        dollarNode5 = self.childNode(withName: "dollar5") as! SKSpriteNode
//        dollarNode6 = self.childNode(withName: "dollar6") as! SKSpriteNode

        selectedAmmoNode = self.childNode(withName: "selectedAmmo") as! SKSpriteNode
        selectedAmmoNode.texture = SKTexture(imageNamed: (players[0].ammo)!)
        selectedShipNode = self.childNode(withName: "selectedShip") as! SKSpriteNode
        selectedShipNode.texture = SKTexture(imageNamed: (players[0].spaceship)!)
        
        cashLabelNode = self.childNode(withName: "cashLabel") as! SKLabelNode
        cashLabelNode.text = String(players[0].score)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            let explosion = SKEmitterNode(fileNamed: "selectItem")!

            switch nodesArray.first?.name{
            case "backToMenuButton":
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene
                self.view?.presentScene(menuScene, transition: transition)
            case "ship1":
                players[0].spaceship = "Spaceship"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ship2":
                players[0].spaceship = "roket"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ship3":
                players[0].spaceship = "mastership"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ammo1":
                players[0].ammo = "red"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ammo2":
                players[0].ammo = "yellow"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ammo3":
                players[0].ammo = "blue"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            default: break
            }
            selectedShipNode.texture = SKTexture(imageNamed: (players.first?.spaceship)!)
            selectedAmmoNode.texture = SKTexture(imageNamed: (players.first?.ammo)!)

            
            self.run(SKAction.wait(forDuration: 1)) {
                explosion.removeFromParent()
            }

            do {
                try self.managedObjectContext.save()
            } catch {
                print("Could not save data \(error.localizedDescription)")
            }
            
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
}
