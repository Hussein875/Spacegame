//
//  ShopScene.swift
//  SpacegameReloaded
//
//  Created by Hussein Souleiman on 12.04.18.
//  Copyright © 2018 Training. All rights reserved.
//

//TODO: Shop anpassen, DB anpassen, Constants anpassen, Buy Button . 
import UIKit
import SpriteKit
import CoreData

class GameRoomTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    var items: [String] = ["Spaceship", "roket", "mastership"]
    var prices: [Int] = [100,1000,10000]
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = String(self.prices[indexPath.row])
        cell.imageView?.image = UIImage(named: self.items[indexPath.row])
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(Constants.currentPlayer.score >= self.prices[indexPath.row]) {
        Constants.currentPlayer.spaceship = self.items[indexPath.row]
        ShopScene.selectedShipNode.texture = SKTexture(imageNamed: (Constants.players.first?.spaceship)!)
        } else {
            tableView.cellForRow(at: indexPath)?.layer.borderColor = UIColor.red.cgColor
            tableView.cellForRow(at: indexPath)?.layer.borderWidth = 2
        }
    }
}

class ShopScene: SKScene {
    
    var gameTableView = GameRoomTableView()
    private var label : SKLabelNode?
    
    var managedObjectContext:NSManagedObjectContext!
    
    var backToMenuButtonNode:SKSpriteNode!
    
    var ship1Node:SKSpriteNode!
    var ship2Node:SKSpriteNode!
    var ship3Node:SKSpriteNode!

    var ammo1Node:SKSpriteNode!
    var ammo2Node:SKSpriteNode!
    var ammo3Node:SKSpriteNode!
    
    static var selectedShipNode:SKSpriteNode!
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
        
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        // Table setup
        gameTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        gameTableView.frame=CGRect(x:0,y:UIScreen.main.bounds.height * 0.2,width: UIScreen.main.bounds.width ,height:UIScreen.main.bounds.height * 0.5)
        self.scene?.view?.addSubview(gameTableView)
        gameTableView.reloadData()
        
        gameTableView.backgroundColor = UIColor.clear
        
        
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
        
        backToMenuButtonNode = self.childNode(withName: "backToMenuButton") as? SKSpriteNode
        backToMenuButtonNode.texture = SKTexture(imageNamed: "startmenuButton")
        
        ship1Node = self.childNode(withName: "ship1") as? SKSpriteNode
        ship2Node = self.childNode(withName: "ship2") as? SKSpriteNode
        ship3Node = self.childNode(withName: "ship3") as? SKSpriteNode
        ammo1Node = self.childNode(withName: "ammo1") as? SKSpriteNode
        ammo2Node = self.childNode(withName: "ammo2") as? SKSpriteNode
        ammo3Node = self.childNode(withName: "ammo3") as? SKSpriteNode
        
 //       dollarNode1 = self.childNode(withName: "dollar1") as? SKSpriteNode
//        dollarNode2 = self.childNode(withName: "dollar2") as! SKSpriteNode
//        dollarNode3 = self.childNode(withName: "dollar3") as! SKSpriteNode
//        dollarNode4 = self.childNode(withName: "dollar4") as! SKSpriteNode
//        dollarNode5 = self.childNode(withName: "dollar5") as! SKSpriteNode
//        dollarNode6 = self.childNode(withName: "dollar6") as! SKSpriteNode

        selectedAmmoNode = self.childNode(withName: "selectedAmmo") as? SKSpriteNode
//        selectedAmmoNode.texture = SKTexture(imageNamed: (players[0].ammo)!)
        ShopScene.selectedShipNode = self.childNode(withName: "selectedShip") as? SKSpriteNode
//        selectedShipNode.texture = SKTexture(imageNamed: (players[0].spaceship)!)
        
        cashLabelNode = self.childNode(withName: "cashLabel") as? SKLabelNode
        cashLabelNode.text = String(Constants.currentPlayer.score)
        
        ammo1Node.shadowedBitMask = 100
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
                gameTableView.isHidden = true
                self.view?.presentScene(menuScene, transition: transition)
            case "ship1":
                if Constants.currentPlayer.score > 100 {
                Constants.currentPlayer.spaceship = "Spaceship"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
                } else {
                    print("Schiff kostet 100 Taken Bra!")
                }
            case "ship2":
                Constants.currentPlayer.spaceship = "roket"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ship3":
                Constants.currentPlayer.spaceship = "mastership"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ammo1":
                Constants.currentPlayer.ammo = "red"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ammo2":
                Constants.currentPlayer.ammo = "yellow"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            case "ammo3":
                Constants.currentPlayer.ammo = "blue"
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
            default: break
            }
            ShopScene.selectedShipNode.texture = SKTexture(imageNamed: (Constants.currentPlayer.spaceship)!)
            selectedAmmoNode.texture = SKTexture(imageNamed: (Constants.currentPlayer.ammo)!)

            
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
            Constants.players = try managedObjectContext.fetch(playerRequest)
        } catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
    }
}
