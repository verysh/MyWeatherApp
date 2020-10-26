//
//  CoreDataManager.swift
//  MyWeatherApp
//
//  Created by VLAD on 20/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CoreDataManager {

    static let sharedInstance = CoreDataManager()
    
    func saveItem(city: String, temp: Double, country: String) {
        
        let managedContext = self.managedObjectContext()
        let entity = NSEntityDescription.entity(forEntityName: "City", in: managedContext)
        
        let item = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        item.setValue(city, forKey: "name")
        item.setValue(temp, forKey: "temp")
        item.setValue(country, forKey: "country")
        
        saveContext()
    }
    
    func saveItem(temp: Double) {
        
        let managedContext = self.managedObjectContext()
        let entity = NSEntityDescription.entity(forEntityName: "City", in: managedContext)
        
        let item = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        item.setValue(temp, forKey: "temp")
        
        saveContext()
    }
    
    
    func fetchRequest() -> [City]  {
        
        var cities = [City]()
        
        let managedContext = self.managedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
        let entityDescription = NSEntityDescription.entity(forEntityName: "City", in: managedContext)
        
        fetchRequest.entity = entityDescription
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest) as! [City]
            for res in results {
                cities.append(res)
                
            }

        } catch  {
            print("error")
        }
        
        return cities
    }
    
    func managedObjectContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MyWeatherApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
