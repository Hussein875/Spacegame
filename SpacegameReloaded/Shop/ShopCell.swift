////
////  ShopCell.swift
////  Space Attack
////
////  Created by Hussein Souleiman on 06.04.19.
////  Copyright © 2019 Training. All rights reserved.
////
//
//
//import UIKit
//
//struct Spaceship {
//    
//    var id : Int
//    var name : String
//    var preis : String
//    var image : String
//    var capacity : Int
//    var damage : Int
//}
//
//class MyCustomCell: UITableViewController {
//    
//    var spaceships = [
//        Spaceship(id: 1, name: "shuttle", preis: "100", image: "shuttle.png", capacity: 50, damage: 10),
//        Spaceship(id: 2, name: "shuttle", preis: "100", image: "roket.png", capacity: 50, damage: 10),
//        Spaceship(id: 3, name: "shuttle", preis: "100", image: "spaceship.png", capacity: 50, damage: 10),
//        Spaceship(id: 4, name: "shuttle", preis: "100", image: "mastership.png", capacity: 50, damage: 10)
//    ]
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return spaceships.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
//        
//        let spaceship = spaceships[indexPath.row]
//        cell.textLabel?.text = spaceship.name
//        cell.textLabel?.text = spaceship.preis
//        cell.imageView?.image = UIImage(named: spaceship.image)
//        
//        return cell
//    }
//    
//}
//
////class MyCustomCell: UITableViewCell {
////
////    var myLabel = UILabel()
////
////    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
////        super.init(style: style, reuseIdentifier: reuseIdentifier)
////
////        myLabel.backgroundColor = UIColor.yellow
////        self.contentView.addSubview(myLabel)
////    }
////
////    required init?(coder aDecoder: NSCoder) {
////        super.init(coder: aDecoder)
////    }
////
////    override func layoutSubviews() {
////        super.layoutSubviews()
////
////        myLabel.frame = CGRect(x: 20, y: 0, width: 70, height: 30)
////    }
////}
