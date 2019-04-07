//
//  Constants.swift
//  Space Attack
//
//  Created by Hussein Souleiman on 06.04.19.
//  Copyright © 2019 Training. All rights reserved.
//

import Foundation
import CoreData


struct Constants {
    static var players = [Player]()
    static var currentPlayer = players[0]
    static var spaceship : Spaceship?
    
    static var spaceships = [
        Spaceship(id: 0, name: "Shuttle", preis: 100, image: "shuttle.png", capacity: 50, damage: 10, ammo: "torpedo.png", laser: false, owned: true),
        Spaceship(id: 1, name: "ship1", preis: 200, image: "ship1.png", capacity: 50, damage: 10, ammo: "ammo1.png", laser: false, owned: false),
        Spaceship(id: 2, name: "ship2", preis: 500, image: "ship2.png", capacity: 50, damage: 10, ammo: "ammo2.png", laser: false, owned: false),
        Spaceship(id: 3, name: "ship3", preis: 1000, image: "ship3.png", capacity: 50, damage: 10, ammo: "ammo3.png", laser: false, owned: false),
        Spaceship(id: 4, name: "ship4", preis: 2000, image: "ship4.png", capacity: 50, damage: 10, ammo: "ammo4.png", laser: false, owned: false),
        Spaceship(id: 5, name: "ship5", preis: 5000, image: "ship5.png", capacity: 50, damage: 10, ammo: "ammo5.png", laser: false, owned: false),
        Spaceship(id: 6, name: "ship6", preis: 8000, image: "ship6.png", capacity: 50, damage: 10, ammo: "ammo6.png", laser: false, owned: false),
        Spaceship(id: 7, name: "ship7", preis: 10000, image: "ship7.png", capacity: 50, damage: 10, ammo: "ammo7.png", laser: false, owned: false),
        Spaceship(id: 8, name: "ship8", preis: 15000, image: "ship8.png", capacity: 50, damage: 10, ammo: "ammo8.png", laser: false, owned: false),
        Spaceship(id: 9, name: "ship9", preis: 20000, image: "ship9.png", capacity: 50, damage: 10, ammo: "ammo9.png", laser: true, owned: false),
    ]
}
