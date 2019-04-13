//
//  LocalDataBase.swift
//  Space Attack
//
//  Created by Hussein Souleiman on 09.04.19.
//  Copyright © 2019 Training. All rights reserved.
//
// Die Locale DB verwaltet die eigenen Raumschiffe

import Foundation
import SQLite

class LocalDatabase {
    
    static let sharedInstance = LocalDatabase()
    
    var database: Connection!
    
    let spaceshipTable = Table("spaceships")
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let preis = Expression<Int>("preis")
    let image = Expression<String>("image")
    let capacity = Expression<Int>("capacity")
    let damage = Expression<Int>("damage")
    let ammo = Expression<String>("ammo")
    let laser = Expression<Bool>("laser")
    let owned = Expression<Bool>("owned")
    
    
    func initilizeDatabase() {
        do {
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("spaceships.sqlite3")
            let database = try Connection(fileURL.path)
            self.database = database

            let createTable = self.spaceshipTable.create(ifNotExists: true) { (table) in
                table.column(self.id, primaryKey: true)
                table.column(self.name)
                table.column(self.preis)
                table.column(self.image)
                table.column(self.capacity)
                table.column(self.damage)
                table.column(self.ammo)
                table.column(self.laser)
                table.column(self.owned)
                
                print("created Table successfully")
            }
            try self.database.run(createTable)
        } catch {
            print(error)
        }
        if(getSpaceshipbyName(name: "Shuttle") == nil) {
            LocalDatabase.sharedInstance.insertSpaceship(spaceship: Constants.spaceships[0])
        }
        LocalDatabase.sharedInstance.listownedships()
    }
    
    func insertSpaceship(spaceship: Spaceship){
        
        let insertSpaceship = self.spaceshipTable.insert(
            //            self.id <- spaceship.id,
            self.name <- spaceship.name,
            self.preis <- spaceship.preis,
            self.image <- spaceship.image,
            self.capacity <- spaceship.capacity,
            self.damage <- spaceship.damage,
            self.ammo <- spaceship.ammo,
            self.laser <- spaceship.laser,
            self.owned <- spaceship.owned
        )
        
        do {
            try self.database.run(insertSpaceship)
            print("inserted Spaceship")
        } catch {
            print(error)
        }
    }
    
    func getSpaceshipbyName(name: String) -> Spaceship?{
        do {
            let spaceships = try self.database.prepare(self.spaceshipTable)
            
            for spaceship in spaceships {
                
                if spaceship[self.name] == name {
                    
                    return Spaceship(id: spaceship[self.id], name: spaceship[self.name], preis: spaceship[self.preis], image: spaceship[self.image], capacity: spaceship[self.capacity], damage: spaceship[self.damage], ammo: spaceship[self.ammo], laser: spaceship[self.laser], owned: spaceship[self.owned])
                }
            }
        }catch {
            print(error)
        }
        return nil
    }
    
    func listownedships(){
        do {
            let spaceships = try self.database.prepare(self.spaceshipTable)
            for spaceship  in spaceships {
                print("Ship: \(spaceship[self.id]) - \(spaceship[self.name])")
            }
        }catch {
            print(error)
        }
    }
    
    func dropTable(){
        let deleteSpaceships = self.spaceshipTable.drop()
        do {
            try self.database.run(deleteSpaceships)
            print("Table spaceships dropped")
        } catch {
            print(error)
        }
    }
    
        
        //    func getUserByName(firstname: String, lastname: String) {
        //        do {
        //            let users = try self.database.prepare(self.usersTable)
        //            for user in users {
        //                if(user[self.firstname] == firstname && user[self.lastname] == lastname) {
        //                    AppModel.shared.currentUser = Employee(firstname: user[self.firstname], lastname: user[self.lastname], isMale: user[self.gender], isAdmin: false, id: user[self.id], scoreFirstname: user[self.scoreFirstname], scoreFullname: user[self.scoreFullname], imageURL: user[self.imageURL])
        //                    print(user[self.id])
        //                }
        //            }
        //
        //        }
        //        catch {
        //            print(error)
        //        }
        //
        //    }
}
