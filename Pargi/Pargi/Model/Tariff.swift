//
//  Tariff.swift
//  Pargi
//
//  Created by Henri Normak on 10/10/15.
//  Copyright © 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

public struct Tariff {
    public struct Day: OptionSetType {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        static let Monday = Day(rawValue: 1)
        static let Tuesday = Day(rawValue: 2)
        static let Wednesday = Day(rawValue: 4)
        static let Thursday = Day(rawValue: 8)
        static let Friday = Day(rawValue: 16)
        static let Saturday = Day(rawValue: 32)
        static let Sunday = Day(rawValue: 64)

        static let All: Day = [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday, .Sunday]
        static let Weekdays: Day = [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday]
        static let Weekend: Day = [.Saturday, .Sunday]
    }
    
    public let days: Day
    public let start: NSTimeInterval?
    public let end: NSTimeInterval?
    
    public let periods: [NSTimeInterval: Float]
    
    public let freePeriod: NSTimeInterval
    public let minPeriod: NSTimeInterval
    public let minAmount: Float?
    
    public init(days: Day, start: NSTimeInterval = 0, end: NSTimeInterval = 86400, periods: [NSTimeInterval: Float], freePeriod: NSTimeInterval = 0, minPeriod: NSTimeInterval = 0, minAmount: Float = 0.0) {
        self.days = days
        self.start = start
        self.end = end
        self.periods = periods
        self.freePeriod = freePeriod
        self.minPeriod = minPeriod
        self.minAmount = minAmount
    }
}

extension Tariff: Persistable {
    init?(managedObject: NSManagedObject) {
        guard let days = (managedObject.valueForKey("days") as? NSNumber)?.unsignedLongValue,
                periods = managedObject.valueForKey("periods") as? [String: NSNumber],
                freePeriod = (managedObject.valueForKey("freePeriod") as? NSNumber)?.doubleValue,
                minPeriod = (managedObject.valueForKey("minPeriod") as? NSNumber)?.doubleValue else {
            return nil
        }
        
        self.days = Day(rawValue: days)
        
        self.freePeriod = freePeriod
        self.minPeriod = minPeriod
        self.minAmount = (managedObject.valueForKey("minAmount") as? NSNumber)?.floatValue
        
        var convertedPeriods = [NSTimeInterval: Float]()
        for (key, value) in periods {
            if let key = Double(key) {
                convertedPeriods[key] = value.floatValue
            }
        }
        
        self.periods = convertedPeriods
        self.start = (managedObject.valueForKey("start") as? NSNumber)?.doubleValue
        self.end = (managedObject.valueForKey("end") as? NSNumber)?.doubleValue
    }
    
    static func entityName(context: NSManagedObjectContext) -> String {
        return "Tariff"
    }
    
    func populateManagedObject(object: NSManagedObject, context: NSManagedObjectContext) {
        if let start = self.start {
            object.setValue(NSNumber(double: start), forKey: "start")
        }
        
        if let end = self.end {
            object.setValue(NSNumber(double: end), forKey: "end")
        }
        
        object.setValue(NSNumber(unsignedLong: self.days.rawValue), forKey: "days")
        object.setValue(NSNumber(double: self.freePeriod), forKey: "freePeriod")
        object.setValue(NSNumber(double: self.minPeriod), forKey: "minPeriod")
        
        var convertedPeriods = [String: NSNumber]()
        for (key, value) in self.periods {
            convertedPeriods["\(key)"] = NSNumber(float: value)
        }
        
        object.setValue(convertedPeriods, forKey: "periods")
        
        if let amount = self.minAmount {
            object.setValue(NSNumber(float: amount), forKey: "minAmount")
        }
    }
}
