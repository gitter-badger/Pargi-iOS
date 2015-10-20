//
//  Provider.swift
//  Pargi
//
//  Created by Henri Normak on 10/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

public struct Provider {
    public let id: UInt32
    public let beaconMajor: UInt16?
    public let name: String
    public let color: String
    
    public init(id: UInt32, beaconMajor: UInt16? = nil, name: String, color: String) {
        self.id = id
        self.beaconMajor = beaconMajor
        self.name = name
        self.color = color
    }
}

extension Provider: UniquelyPersistable {
    init?(managedObject: NSManagedObject) {
        guard let id = (managedObject.valueForKey("identifier") as? NSNumber)?.unsignedIntValue,
                name = managedObject.valueForKey("name") as? String,
               color = managedObject.valueForKey("hexColor") as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.color = color
        self.beaconMajor = (managedObject.valueForKey("beaconMajor") as? NSNumber)?.unsignedShortValue
    }
    
    static func entityName(context: NSManagedObjectContext) -> String {
        return "Provider"
    }
    
    func populateManagedObject(object: NSManagedObject, context: NSManagedObjectContext) {
        object.setValue(NSNumber(unsignedInt: self.id), forKey: "identifier")
        object.setValue(self.name, forKey: "name")
        object.setValue(self.color, forKey: "hexColor")
        
        if let major = self.beaconMajor {
            object.setValue(NSNumber(unsignedShort: major), forKey: "beaconMajor")
        }
    }
    
    func uniqueProperties(context: NSManagedObjectContext) -> [String: AnyObject] {
        return ["identifier": NSNumber(unsignedInt: self.id)]
    }
}

extension Provider: Fetchable {
    static func fetch(identifier: UInt32, context: NSManagedObjectContext = DataStore.sharedInstance.context) throws -> Provider? {
        let predicate = NSPredicate(format: "identifier = %@", NSNumber(unsignedInt: identifier))
        let results = try self.fetch(context, predicate: predicate) { fetch in
            fetch.fetchLimit = 1
        }
        
        return results.first
    }
}
