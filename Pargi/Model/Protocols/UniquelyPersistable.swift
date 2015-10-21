//
//  UniquelyPersistable.swift
//  Pargi
//
//  Teatud objektid võivad vajada unikaalsust andmebaasis,
//  selle saab tagada, kuid seda tasuks vaadata kui lisakeerukust
//  lihtsalt salvestamise kõrval
//
//  Created by Henri Normak on 12/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

protocol UniquelyPersistable: Persistable {
    // Core Datas unikaalseks muutmine
    func uniqueProperties(context: NSManagedObjectContext) -> [String: AnyObject]
    
    // Valikuline salvestamine
    func persistIfExists(context: NSManagedObjectContext) -> NSManagedObject?
}

extension UniquelyPersistable {
    func uniqueProperties(context: NSManagedObjectContext = DataStore.sharedInstance.context) -> [String: AnyObject] {
        return [:]
    }
    
    func persistIfExists(context: NSManagedObjectContext = DataStore.sharedInstance.context) -> NSManagedObject? {
        let entityName = self.dynamicType.entityName(context)
        let uniqueProps = self.uniqueProperties(context)
        
        let fetch = NSFetchRequest(entityName: entityName)
        fetch.fetchLimit = 1
        
        var predicates = [NSPredicate]()
        for (key, value) in uniqueProps {
            predicates.append(NSPredicate(format: "%K = %@", argumentArray: [key, value]))
        }
        
        fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        var result: NSManagedObject? = nil
        
        context.performBlockAndWait {
            do {
                let results = try context.executeFetchRequest(fetch)
                if let results = results as? [NSManagedObject], object = results.first {
                    self.populateManagedObject(object, context: context)
                    result = object
                }
            } catch let error {
                print("Fetch failed \(error)")
            }
        }
        
        return result
    }
    
    func persist(context: NSManagedObjectContext = DataStore.sharedInstance.context) -> NSManagedObject {
        if let existing = self.persistIfExists(context) {
            return existing
        }
        
        let entityName = self.dynamicType.entityName(context)
        let result = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
        self.populateManagedObject(result, context: context)
        
        return result
    }
}
