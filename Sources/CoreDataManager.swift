//
//  CoreDataManager.swift
//  BroBot
//
//  Created by Carlos Quant on 8/28/17.
//
//

import Foundation
import CoreData

let DB_Name = "BroBot"

fileprivate class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    class func saveCoreDataContext(){
        
    }
    
    // MARK: - CoreData Stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.PN.Brobot" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: DB_Name, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(DB_Name).sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

struct CDManager {
    static func insertHero(_ heroDict:[String:Any]) {
        let context = CoreDataStack.shared.managedObjectContext
        context.perform {
            let entityDescription = NSEntityDescription.entity(forEntityName: "Hero", in: context)
            let hero = Hero(entity: entityDescription!, insertInto: context)
            
            hero.id = heroDict["id"] as! Int64
            hero.name = heroDict["name"] as? String
            hero.localized_name = heroDict["localized_name"] as? String
            hero.primary_attr = heroDict["primary_attr"] as? String
            hero.attack_type = heroDict["attack_type"] as? String
            hero.legs = heroDict["legs"] as! Int64
            
            let rolesArray = heroDict["roles"] as! [String]
            hero.roles = rolesArray.joined(separator: ", ")
            if let urlName = hero.localized_name?.replacingOccurrences(of: " ", with: "_") {
                hero.image = "http://cdn.dota2.com/apps/dota2/images/heroes/\(urlName.lowercased())_full.png"
                hero.image_vert = "http://cdn.dota2.com/apps/dota2/images/heroes/\(urlName.lowercased())_vert.jpg"
                hero.url = "https://dota2.gamepedia.com/\(urlName)"
            }
            
            do {
                try context.save()
            } catch {
                print("Error inserting Hero \(error)")
            }
        }
    }
    
    static func fetch(hero id: Int64) -> Hero? {
        let request: NSFetchRequest = Hero.fetchRequest()
        let idString = "\(id)"
        
        request.predicate = NSPredicate(format: "id == %@", idString)
        
        let results = try? CoreDataStack.shared.managedObjectContext.fetch(request)
        return results?.last
    }
    
    static func fetch(hero name: String) -> Hero? {
        let request: NSFetchRequest = Hero.fetchRequest()

        request.predicate = NSPredicate(format: "localized_name == %@", name)
        
        let results = try? CoreDataStack.shared.managedObjectContext.fetch(request)
        return results?.last
    }
}

