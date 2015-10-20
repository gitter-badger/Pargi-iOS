//
//  ZoneGroup.swift
//  Pargi
//
//  Created by Henri Normak on 10/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

public struct ZoneGroup {
    public let reason: String
    public let name: String
    private let localizedName: String?
    
    public let zones: [Zone]
    
    public init(reason: String, name: String, zones: [Zone]) {
        self.reason = reason
        self.name = name
        self.zones = zones
        self.localizedName = nil
    }
    
    public init(reason: String, localizedName: String, zones: [Zone]) {
        self.reason = reason
        self.name = NSLocalizedString(localizedName, comment: "Localized zone name")
        self.localizedName = localizedName
        self.zones = zones
    }
}

extension ZoneGroup: UniquelyPersistable {
    init?(managedObject: NSManagedObject) {
        guard let reason = managedObject.valueForKey("reason") as? String,
                name = managedObject.valueForKey("name") as? String,
                zones = managedObject.valueForKey("zones") as? NSSet else {
            return nil
        }
        
        self.zones = zones.filter({ $0 is NSManagedObject }).map({ $0 as! NSManagedObject }).flatMap({ Zone.init(managedObject: $0) })
        
        if let localizedName = managedObject.valueForKey("localizedName") as? String {
            self.localizedName = localizedName
            self.name = NSLocalizedString(localizedName, comment: "Localized zone group name")
        } else {
            self.name = name
            self.localizedName = nil
        }
        
        self.reason = reason
    }
    
    static func entityName(context: NSManagedObjectContext) -> String {
        return "ZoneGroup"
    }
    
    func populateManagedObject(object: NSManagedObject, context: NSManagedObjectContext) {
        object.setValue(self.reason, forKey: "reason")
        object.setValue(self.name, forKey: "name")
        object.setValue(self.localizedName, forKey: "localizedName")
        
        let zones = NSSet(array: self.zones.map({ $0.persist(context) }))
        object.setValue(zones, forKey: "zones")
    }
    
    func uniqueProperties(context: NSManagedObjectContext) -> [String : AnyObject] {
        return ["reason": self.reason, "name": self.name]
    }
}

extension ZoneGroup: Fetchable {
    
}
