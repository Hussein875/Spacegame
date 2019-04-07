//
//  Spaceship.swift
//  Space Attack
//
//  Created by Hussein Souleiman on 07.04.19.
//  Copyright © 2019 Training. All rights reserved.
//

import Foundation

struct Spaceship {
    
    var id : Int
    var name : String
    var preis : Int
    var image : String
    var capacity : Int
    var damage : Int
    var ammo : String
    var laser : Bool
    var owned : Bool
    
    init(id:Int, name:String, preis:Int, image:String, capacity:Int, damage: Int, ammo: String, laser:Bool, owned:Bool ) {
        self.id = id
        self.name = name
        self.preis = preis
        self.image = image
        self.capacity = capacity
        self.damage = damage
        self.ammo = ammo
        self.laser = laser
        self.owned = owned
    }
}
