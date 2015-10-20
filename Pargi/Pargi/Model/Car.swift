//
//  Car.swift
//  Pargi
//
//  Created by Henri Normak on 10/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

public struct Car {
    public let license: String
    public var name: String?
    
    public init(license: String, name: String? = nil) {
        self.license = license
        self.name = name
    }
}

extension Car: UniquelyPersistable {
    init?(managedObject: NSManagedObject) {
        guard let license = managedObject.valueForKey("license") as? String else {
            return nil
        }
        
        self.license = license
        self.name = managedObject.valueForKey("name") as? String
    }
    
    static func entityName(context: NSManagedObjectContext) -> String {
        return "Car"
    }
    
    func populateManagedObject(object: NSManagedObject, context: NSManagedObjectContext) {
        object.setValue(self.license, forKey: "license")
        object.setValue(self.name, forKey: "name")
    }
    
    func uniqueProperties(context: NSManagedObjectContext) -> [String: AnyObject] {
        return ["license": self.license]
    }
}

extension Car: Fetchable {
    static func fetch(license: String, context: NSManagedObjectContext = DataStore.sharedInstance.context) throws -> Car? {
        let predicate = NSPredicate(format: "license = %@", license)
        let cars = try self.fetch(context, predicate: predicate, configure: { fetch in
            fetch.fetchLimit = 1
        })
        
        return cars.first
    }
}
