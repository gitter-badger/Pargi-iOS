//
//  Fetchable.swift
//  Pargi
//
//  Protokoll, mis kirjeldab otsitavaid elemente,
//  olgu märgitud, et selleks, et olla otsitav, peaks element
//  olema salvestatav
//
//  Created by Henri Normak on 12/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

protocol Fetchable: Persistable {
    // Keerukamate päringute jaoks saab otse kasutada NSManagedObject elemente
    static func fetchRaw(context: NSManagedObjectContext, predicate: NSPredicate?, configure: (NSFetchRequest -> Void)?) throws -> [NSManagedObject]
    
    static func fetch(context: NSManagedObjectContext, predicate: NSPredicate?, configure: (NSFetchRequest -> Void)?) throws -> [Self]
    static func all(context: NSManagedObjectContext) -> [Self]
}

extension Fetchable {
    static func fetchRaw(context: NSManagedObjectContext, predicate: NSPredicate?, configure: (NSFetchRequest -> Void)?) throws -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: self.entityName(context))
        fetchRequest.predicate = predicate
        
        if let configure = configure {
            configure(fetchRequest)
        }
        
        var result: [NSManagedObject] = []
        var error: ErrorType? = nil
        
        context.performBlockAndWait {
            do {
                result = (try context.executeFetchRequest(fetchRequest)) as! [NSManagedObject]
            } catch let err {
                error = err
            }
        }
        
        if let error = error {
            throw error
        }
        
        return result
    }

    static func fetch(context: NSManagedObjectContext = DataStore.sharedInstance.context, predicate: NSPredicate? = nil, configure: (NSFetchRequest -> Void)? = nil) throws -> [Self] {
        let raw = try self.fetchRaw(context, predicate: predicate, configure: configure)
        return raw.flatMap({ Self(managedObject: $0) })
    }
    
    static func all(context: NSManagedObjectContext = DataStore.sharedInstance.context) -> [Self] {
        return (try? self.fetch(context)) ?? []
    }
}
