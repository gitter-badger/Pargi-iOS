//
//  ParkEvent.swift
//  Pargi
//
//  Created by Henri Normak on 10/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

public struct ParkEvent {
    public enum Status: Int16 {
        case Ready
        case Parking
        case Ending
        case Ended
    }
    
    private(set) public var status: Status = .Ready
    
    private(set) public var startDate: NSDate?
    private(set) public var endDate: NSDate?
    
    public var duration: NSTimeInterval? {
        get {
            guard let endDate = self.endDate, startDate = self.startDate else {
                return nil
            }
            
            return endDate.timeIntervalSinceDate(startDate)
        }
    }
    
    public let zone: Zone
    public let car: Car
    
    public init(zone: Zone, car: Car) {
        self.zone = zone
        self.car = car
    }
    
    // MARK: Altering state
    
    private func isStateChangeAllowed(from: Status, to: Status) -> Bool {
        switch (from, to) {
        case (.Ready, .Parking), (.Parking, .Ending), (.Ending, .Ended):
            return true
        case (.Ready, .Ending):
            return true
        default:
            return false
        }
    }
    
    mutating func transition(status: Status) -> Bool {
        guard self.isStateChangeAllowed(self.status, to: status) else {
            return false
        }
        
        switch status {
        case .Parking:
            self.startDate = NSDate()
        case .Ended:
            self.endDate = NSDate()
        default:
            break
        }
        
        self.status = status
        return true
    }
}

extension ParkEvent: Persistable {
    init?(managedObject: NSManagedObject) {
        guard let statusInt = (managedObject.valueForKey("status") as? NSNumber)?.shortValue,
                carObject = managedObject.valueForKey("car") as? NSManagedObject,
                zoneObject = managedObject.valueForKey("eventZone") as? NSManagedObject else {
            return nil
        }
        
        guard let car = Car(managedObject: carObject), zone = Zone(managedObject: zoneObject), status = Status(rawValue: statusInt) else {
            return nil
        }
        
        self.car = car
        self.zone = zone
        self.status = status
    }
    
    static func entityName(context: NSManagedObjectContext) -> String {
        return "ParkEvent"
    }
    
    func populateManagedObject(object: NSManagedObject, context: NSManagedObjectContext) {
        object.setValue(NSNumber(short: self.status.rawValue), forKey: "status")
        
        let carObject = self.car.persist(context)
        object.setValue(carObject, forKey: "car")
        
        let zoneObject = self.zone.persist(context)
        object.setValue(zoneObject, forKey: "eventZone")
    }
}

extension ParkEvent: Fetchable {
    static func fetch(car: Car, context: NSManagedObjectContext = DataStore.sharedInstance.context) throws -> [ParkEvent] {
        guard let managedObject = car.persistIfExists(context) else {
            return []
        }
        
        let predicate = NSPredicate(format: "car = %@", managedObject)
        return try self.fetch(context, predicate: predicate)
    }
}
