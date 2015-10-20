//
//  Zone.swift
//  Pargi
//
//  Created by Henri Normak on 10/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import CoreData

public struct Zone {
    public struct Region {
        let points: [CLLocationCoordinate2D]
        let interiorRegions: [Region]?
        
        init(points: [CLLocationCoordinate2D], interiorRegions: [Region]? = nil) {
            self.points = points
            self.interiorRegions = interiorRegions
        }
    }
    
    public let id: UInt32
    public let code: String
    public let beaconMinor: Int16?
    
    public let regions: [Region]
    public let tariffs: [Tariff]
    
    public let provider: Provider
    
    init(id: UInt32, code: String, beaconMinor: Int16? = nil, provider: Provider, regions: [Region], tariffs: [Tariff]) {
        self.id = id
        self.code = code
        self.beaconMinor = beaconMinor
        self.provider = provider
        self.regions = regions
        self.tariffs = tariffs
    }
}

extension Zone.Region: Persistable, Fetchable {
    init?(managedObject: NSManagedObject) {
        guard let pointsObjects = managedObject.valueForKey("points") as? NSSet else {
            return nil
        }
        
        self.points = pointsObjects.map({ $0 as! NSManagedObject }).map({ point in
            let latitude = (point.valueForKey("latitude") as? NSNumber)!.doubleValue
            let longitude = (point.valueForKey("longitude") as? NSNumber)!.doubleValue
            
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        })
        
        if let interiorRegions = managedObject.valueForKey("interiorRegions") as? NSSet {
            self.interiorRegions = interiorRegions.flatMap({ Zone.Region(managedObject: ($0 as! NSManagedObject)) })
        } else {
            self.interiorRegions = nil
        }
    }
    
    static func entityName(context: NSManagedObjectContext) -> String {
        return "ZoneRegion"
    }
    
    func populateManagedObject(object: NSManagedObject, context: NSManagedObjectContext) {
        let points = self.points.map({ point -> NSManagedObject in
            let entity = NSEntityDescription.insertNewObjectForEntityForName("ZoneRegionPoint", inManagedObjectContext: context)
            entity.setValue(NSNumber(double: point.latitude), forKey: "latitude")
            entity.setValue(NSNumber(double: point.longitude), forKey: "longitude")
            entity.setValue(object, forKey: "parentRegion")
            
            return entity
        })
        
        object.setValue(NSOrderedSet(array: points), forKey: "points")
        
        if let interiorRegions = self.interiorRegions {
            let regions = interiorRegions.map({ $0.persist(context) })
            object.setValue(NSSet(array: regions), forKey: "interiorRegions")
        }
    }
}

extension Zone: UniquelyPersistable {
    init?(managedObject: NSManagedObject) {
        guard let id = (managedObject.valueForKey("identifier") as? NSNumber)?.unsignedIntValue,
            code = managedObject.valueForKey("code") as? String,
            providerObject = managedObject.valueForKey("provider") as? NSManagedObject,
            provider = Provider(managedObject: providerObject) else {
            return nil
        }
        
        self.id = id
        self.code = code
        self.provider = provider
        self.beaconMinor = (managedObject.valueForKey("beaconMinor") as? NSNumber)?.shortValue
        
        guard let regionObjects = managedObject.valueForKey("regions") as? NSSet,
                  tariffObjects = managedObject.valueForKey("tariffs") as? NSSet else {
            return nil
        }
        
        self.regions = regionObjects.flatMap({ Zone.Region(managedObject: ($0 as! NSManagedObject)) })
        self.tariffs = tariffObjects.flatMap({ Tariff(managedObject: ($0 as! NSManagedObject)) })
    }
    
    static func entityName(context: NSManagedObjectContext) -> String {
        return "Zone"
    }
    
    func populateManagedObject(object: NSManagedObject, context: NSManagedObjectContext) {
        object.setValue(NSNumber(unsignedInt: self.id), forKey: "identifier")
        object.setValue(self.code, forKey: "code")
        
        if let minor = self.beaconMinor {
            object.setValue(NSNumber(short: minor), forKey: "beaconMinor")
        }
        
        let regionObjects = self.regions.map({ $0.persist(context) })
        let tariffObjects = self.tariffs.map({ $0.persist(context) })
        let providerObject = self.provider.persist(context)
        
        object.setValue(NSSet(array: regionObjects), forKey: "regions")
        object.setValue(NSSet(array: tariffObjects), forKey: "tariffs")
        object.setValue(providerObject, forKey: "provider")
        
        for region in regionObjects {
            region.setValue(object, forKey: "parentZone")
            print("region \(region) setting parent to \(object)")
        }
        
        for tariff in tariffObjects {
            tariff.setValue(object, forKey: "parentZone")
            print("tariff \(tariff) setting parent to \(object)")
        }
    }
    
    func uniqueProperties(context: NSManagedObjectContext) -> [String : AnyObject] {
        return ["code": self.code]
    }
}

private extension CLLocationCoordinate2D {
    func translate(longitude: CLLocationDistance, latitude: CLLocationDistance) -> CLLocationCoordinate2D {
        let region = MKCoordinateRegionMakeWithDistance(self, latitude, longitude)
        let span = region.span
        
        return CLLocationCoordinate2D(latitude: self.latitude + span.latitudeDelta, longitude: self.longitude + span.longitudeDelta)
    }
}

extension Zone: Fetchable {
    static func fetch(code: String, context: NSManagedObjectContext = DataStore.sharedInstance.context) throws -> [Zone] {
        let predicate = NSPredicate(format: "code CONTAINS[c] %@", code)
        return try self.fetch(context, predicate: predicate)
    }
    
    static func fetch(provider: Provider, context: NSManagedObjectContext = DataStore.sharedInstance.context) throws -> [Zone] {
        guard let managedObject = provider.persistIfExists(context) else {
            return []
        }
        
        let predicate = NSPredicate(format: "provider = %@", managedObject)
        return try self.fetch(context, predicate: predicate)
    }
    
    static func fetch(center: CLLocationCoordinate2D, distance: CLLocationDistance, context: NSManagedObjectContext = DataStore.sharedInstance.context) throws -> [Zone] {
        let top = center.translate(distance, latitude: 0.0)
        let bottom = center.translate(-distance, latitude: 0.0)
        let right = center.translate(0.0, latitude: distance)
        let left = center.translate(0.0, latitude: -distance)
        
        var predicate = NSPredicate(format: "(SUBQUERY(points, $x, $x.latitude >= %f AND $x.latitude <= %f AND $x.longitude >= %f AND $x.longitude <= %f).@count > 0)", left.latitude, right.latitude, bottom.longitude, top.longitude)
        
        let regions = try Zone.Region.fetchRaw(context, predicate: predicate, configure: nil)
        
        predicate = NSPredicate(format: "ANY regions IN %@", regions)
        
        // TODO: Ei toimi aladega, mis lõikuvad otsingut puudutava ringiga, samuti ei leia neid, mis täielikult hõlmavad otsinguala
        return try Zone.fetch(context, predicate: predicate)
    }
}
