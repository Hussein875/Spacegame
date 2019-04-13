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
    
    
    
    //    var items: [String] = ["Spaceship", "roket", "mastership"]
    //    var prices: [Int] = [100,1000,10000]
    
    
    
    
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
        return Constants.spaceships.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let spaceship = Constants.spaceships[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = String(spaceship.name)
        
        if(LocalDatabase.sharedInstance.getSpaceshipbyName(name: spaceship.name) != nil){
            cell.textLabel?.textColor = UIColor.green
        } else {
            cell.textLabel?.textColor = UIColor.white
        }
        //cell.selectionStyle = .none
        cell.imageView?.image = UIImage(named: spaceship.image)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LocalDatabase.sharedInstance.listownedships()
        let selectedSpaceship = Constants.spaceships[indexPath.row]
        if let selectedSpaceship = LocalDatabase.sharedInstance.getSpaceshipbyName(name: selectedSpaceship.name) {
            print(selectedSpaceship)
            ShopScene.selectedShipNode.texture = SKTexture(imageNamed: (selectedSpaceship.image))
            ShopScene.selectedAmmoNode.texture = SKTexture(imageNamed: (selectedSpaceship.ammo))
            ShopScene.preisNode.text = String(selectedSpaceship.preis)
            ShopScene.spaceName = String(selectedSpaceship.image)
            ShopScene.ammoName = String(selectedSpaceship.ammo)
            ShopScene.selectedSpaceship = selectedSpaceship
            
            ShopScene.kaufenBtnNode.texture = SKTexture(imageNamed:"button_auswaehlen")
        } else {
            ShopScene.selectedShipNode.texture = SKTexture(imageNamed: (selectedSpaceship.image))
            ShopScene.selectedAmmoNode.texture = SKTexture(imageNamed: (selectedSpaceship.ammo))
            ShopScene.preisNode.text = String(selectedSpaceship.preis)
            ShopScene.spaceName = String(selectedSpaceship.image)
            ShopScene.ammoName = String(selectedSpaceship.ammo)
            ShopScene.selectedSpaceship = Constants.spaceships[indexPath.row]
            
            ShopScene.kaufenBtnNode.texture = SKTexture(imageNamed:"button_kaufen")
            
        }
    }
}



class ShopScene: SKScene {
    
    var gameTableView = GameRoomTableView()
    private var label : SKLabelNode?
    
    var managedObjectContext:NSManagedObjectContext!
    
    var backToMenuButtonNode:SKSpriteNode!
    
    static var selectedShipNode:SKSpriteNode!
    static var selectedAmmoNode:SKSpriteNode!
    static var selectedSpaceship:Spaceship?
    
    static var kaufenBtnNode:SKSpriteNode!
    
    static var cashLabelNode:SKLabelNode!
    static var preisNode:SKLabelNode!
    static var spaceName:String = ""
    static var ammoName:String = ""
    
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
        
        backToMenuButtonNode = self.childNode(withName: "button_startmenu") as? SKSpriteNode
        backToMenuButtonNode.texture = SKTexture(imageNamed: "button_startmenu")
        
        ShopScene.kaufenBtnNode = self.childNode(withName: "button_kaufen") as? SKSpriteNode
        ShopScene.kaufenBtnNode.texture = SKTexture(imageNamed:"button_kaufen")
        
        ShopScene.preisNode = self.childNode(withName: "preisLabelNode") as? SKLabelNode
        ShopScene.preisNode.text = "Preis"
        
        ShopScene.selectedAmmoNode = self.childNode(withName: "selectedAmmo") as? SKSpriteNode
        ShopScene.selectedAmmoNode.texture = SKTexture(imageNamed: (Constants.players[0].ammo)!)
        ShopScene.selectedShipNode = self.childNode(withName: "selectedShip") as? SKSpriteNode
        ShopScene.selectedShipNode.texture = SKTexture(imageNamed: (Constants.players[0].spaceship)!)
        
        ShopScene.cashLabelNode = self.childNode(withName: "cashLabel") as? SKLabelNode
        ShopScene.cashLabelNode.text = String(Constants.currentPlayer.score)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            let explosion = SKEmitterNode(fileNamed: "selectItem")!
            
            
            switch nodesArray.first?.name{
            case "button_startmenu":
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene
                gameTableView.isHidden = true
                self.view?.presentScene(menuScene, transition: transition)
                break
            case "button_kaufen":
                if ShopScene.selectedSpaceship?.owned == true {
                    print("Ship ausgewählt!")
                    if let spaceship = ShopScene.selectedSpaceship{
                        Constants.spaceship = spaceship
                        Constants.currentPlayer.spaceship = spaceship.image
                        Constants.currentPlayer.ammo = spaceship.ammo
                        Constants.currentPlayer.shipname = spaceship.name
                    }
                } else {
                    if let preis = Int(ShopScene.preisNode.text!) {
                        if Constants.currentPlayer.score >= preis {
                            
                            if var spaceship = ShopScene.selectedSpaceship{
                                Constants.spaceship = spaceship
                                Constants.currentPlayer.spaceship = spaceship.image
                                Constants.currentPlayer.ammo = spaceship.ammo
                                Constants.currentPlayer.score -= Int32(preis)
                                Constants.currentPlayer.shipname = spaceship.name
                                ShopScene.cashLabelNode.text = String(Constants.currentPlayer.score)
                                spaceship.owned = true
                                Constants.spaceships[spaceship.id].owned = true
                                
                                ShopScene.selectedSpaceship = spaceship
                                ShopScene.kaufenBtnNode.texture = SKTexture(imageNamed:"button_auswaehlen")
                                
                                LocalDatabase.sharedInstance.insertSpaceship(spaceship: spaceship)
                            }
                        }
                    } else {
                        print("Nicht genug Geld")
                    }
                    
                }
                explosion.position = (nodesArray.first?.position)!
                self.addChild(explosion)
                break
            default: break
            }
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
