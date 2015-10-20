//
//  Persistable.swift
//  Pargi
//
//  Protokoll, mis kirjeldab elemente, mida saab Core Datasse salvestada
//  ning sealt välja otsida
//
//  Created by Henri Normak on 10/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

protocol Persistable {
    // Core Datast välja laadimine
    init?(managedObject: NSManagedObject)
    
    // Objekti informatsioon
    static func entityName(context: NSManagedObjectContext) -> String
    
    // Core Datasse sisse laadimine
    func populateManagedObject(object: NSManagedObject, context: NSManagedObjectContext) -> Void
    
    // Salvestamine (mis kas uuendab või loob uue objekti)
    func persist(context: NSManagedObjectContext) -> NSManagedObject
}

extension Persistable {
    func persist(context: NSManagedObjectContext = DataStore.sharedInstance.context) -> NSManagedObject {
        let entityName = self.dynamicType.entityName(context)
        let result = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
        self.populateManagedObject(result, context: context)
        
        return result
    }
}
