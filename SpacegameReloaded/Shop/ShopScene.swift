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
    
    struct Spaceship {
        
        var id : Int
        var name : String
        var preis : Int
        var image : String
        var capacity : Int
        var damage : Int
        var ammo : String
    }
    
//    var items: [String] = ["Spaceship", "roket", "mastership"]
//    var prices: [Int] = [100,1000,10000]
    
    var spaceships = [
        Spaceship(id: 1, name: "Shuttle", preis: 100, image: "shuttle.png", capacity: 50, damage: 10, ammo: "torpedo.png"),
        Spaceship(id: 2, name: "ship1", preis: 200, image: "ship1.png", capacity: 50, damage: 10, ammo: "ammo1.png"),
        Spaceship(id: 3, name: "ship2", preis: 500, image: "ship2.png", capacity: 50, damage: 10, ammo: "ammo2.png"),
        Spaceship(id: 4, name: "ship3", preis: 1000, image: "ship3.png", capacity: 50, damage: 10, ammo: "ammo3.png"),
        Spaceship(id: 5, name: "ship4", preis: 2000, image: "ship4.png", capacity: 50, damage: 10, ammo: "ammo4.png"),
        Spaceship(id: 6, name: "ship5", preis: 5000, image: "ship5.png", capacity: 50, damage: 10, ammo: "ammo5.png"),
        Spaceship(id: 7, name: "ship6", preis: 8000, image: "ship6.png", capacity: 50, damage: 10, ammo: "ammo6.png"),
        Spaceship(id: 8, name: "ship7", preis: 10000, image: "ship7.png", capacity: 50, damage: 10, ammo: "ammo7.png"),
        Spaceship(id: 9, name: "ship8", preis: 15000, image: "ship8.png", capacity: 50, damage: 10, ammo: "ammo8.png"),
        Spaceship(id: 10, name: "ship9", preis: 20000, image: "ship9.png", capacity: 50, damage: 10, ammo: "ammo9.png"),
    ]
    
    
    override init(frame: CGRect, style: UITableView.Style) {
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
        return spaceships.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let spaceship = spaceships[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = String(spaceship.name)
        cell.textLabel?.textColor = UIColor.white
        //cell.selectionStyle = .none
        cell.imageView?.image = UIImage(named: spaceship.image)

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSpaceship = self.spaceships[indexPath.row]
        ShopScene.selectedShipNode.texture = SKTexture(imageNamed: (selectedSpaceship.image))
        ShopScene.selectedAmmoNode.texture = SKTexture(imageNamed: (selectedSpaceship.ammo))
        ShopScene.preisNode.text = String(selectedSpaceship.preis)
        ShopScene.spaceName = String(selectedSpaceship.image)
        ShopScene.ammoName = String(selectedSpaceship.ammo)
        
//        if(Constants.currentPlayer.score >= self.spaceships[indexPath.row].preis) {
//            Constants.currentPlayer.spaceship = self.spaceships[indexPath.row].name
//            Constants.currentPlayer.ammo = self.spaceships[indexPath.row].ammo
//        Constants.currentPlayer.score -= Int32(self.spaceships[indexPath.row].preis)
//        }
    }
}



class ShopScene: SKScene {
    
    var gameTableView = GameRoomTableView()
    private var label : SKLabelNode?
    
    var managedObjectContext:NSManagedObjectContext!
    
    var backToMenuButtonNode:SKSpriteNode!
    
    static var selectedShipNode:SKSpriteNode!
    static var selectedAmmoNode:SKSpriteNode!
    
    static var kaufenBtnNode:SKSpriteNode!
    
    static var cashLabelNode:SKLabelNode!
    static var preisNode:SKLabelNode!
    static var spaceName:String = "shuttle"
    static var ammoName:String = "torpedo"

    var starfield: SKEmitterNode!
    
    override func didMove(to view: SKView) {
        
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        // Table setup
        gameTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        gameTableView.frame=CGRect(x:0,y:UIScreen.main.bounds.height * 0.15,width: UIScreen.main.bounds.width ,height:UIScreen.main.bounds.height * 0.4)
        self.scene?.view?.addSubview(gameTableView)
        gameTableView.rowHeight = 75
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
        
        ShopScene.kaufenBtnNode = self.childNode(withName: "kaufenBtn") as? SKSpriteNode
        ShopScene.kaufenBtnNode.texture = SKTexture(imageNamed: "kaufenbtn")
        
        ShopScene.preisNode = self.childNode(withName: "preisLabelNode") as? SKLabelNode
        ShopScene.preisNode.text = "Preis"
        
//        ship1Node = self.childNode(withName: "ship1") as? SKSpriteNode
//        ship2Node = self.childNode(withName: "ship2") as? SKSpriteNode
//        ship3Node = self.childNode(withName: "ship3") as? SKSpriteNode
//        ammo1Node = self.childNode(withName: "ammo1") as? SKSpriteNode
//        ammo2Node = self.childNode(withName: "ammo2") as? SKSpriteNode
//        ammo3Node = self.childNode(withName: "ammo3") as? SKSpriteNode
        
 //       dollarNode1 = self.childNode(withName: "dollar1") as? SKSpriteNode
//        dollarNode2 = self.childNode(withName: "dollar2") as! SKSpriteNode
//        dollarNode3 = self.childNode(withName: "dollar3") as! SKSpriteNode
//        dollarNode4 = self.childNode(withName: "dollar4") as! SKSpriteNode
//        dollarNode5 = self.childNode(withName: "dollar5") as! SKSpriteNode
//        dollarNode6 = self.childNode(withName: "dollar6") as! SKSpriteNode

        ShopScene.selectedAmmoNode = self.childNode(withName: "selectedAmmo") as? SKSpriteNode
//        selectedAmmoNode.texture = SKTexture(imageNamed: (players[0].ammo)!)
        ShopScene.selectedShipNode = self.childNode(withName: "selectedShip") as? SKSpriteNode
//        selectedShipNode.texture = SKTexture(imageNamed: (players[0].spaceship)!)
        
        ShopScene.cashLabelNode = self.childNode(withName: "cashLabel") as? SKLabelNode
        ShopScene.cashLabelNode.text = String(Constants.currentPlayer.score)
        
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
            case "kaufenBtn":
                let preis : Int = Int(ShopScene.preisNode.text ?? "9999")!
                if Constants.currentPlayer.score >= preis {
                    Constants.currentPlayer.spaceship = ShopScene.spaceName
                    Constants.currentPlayer.ammo = ShopScene.ammoName
                    Constants.currentPlayer.score -= Int32(preis)
                    ShopScene.cashLabelNode.text = String(Constants.currentPlayer.score)
                
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
                } else {
                    print("Schiff kostet 100 Taken Bra!")
                }
            default: break
            }
//            ShopScene.selectedShipNode.texture = SKTexture(imageNamed: (Constants.currentPlayer.spaceship)!)
//            ShopScene.selectedAmmoNode.texture = SKTexture(imageNamed: (Constants.currentPlayer.ammo)!)

            
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
