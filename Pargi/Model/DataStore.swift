//
//  DataStore.swift
//  Pargi
//
//  Andmebaasi laadimise ja kasutamise eest vastutav klass
//  Aitab koordineerida andmete salvestamist ja vajadusel
//  taustal töötlemist
//
//  Created by Henri Normak on 10/02/2015.
//  Copyright (c) 2015 Henri Normak. All rights reserved.
//

import Foundation
import CoreData

public class DataStore: NSObject {
    // Veakoodid
    public enum Error: ErrorType {
        case InvalidModel
    }
    
    // Mudel ja andmebaasi nimi on konstantne, vähemalt seni kuni ei ole
    // migratsiooni näiteks erinevate versioonide vahel
    let storeName = "Pargi"
    let storeFilename = "Pargi.sqlite"
    
    // Konteksti nimi, võimalik, et kasutatakse logides
    let mainContextName = "Main"
    public var context: NSManagedObjectContext!
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    private static var shared: DataStore!
    
    /// Jagatud DataStore, peamine, mida rakendus kasutama peaks
    public class var sharedInstance : DataStore {
        return shared
    }
    
    public class func initializeSharedInstance(callback: ((Bool, ErrorType?) -> Void)?) {
        shared = DataStore(callback: callback)
    }
    
    // MARK: Funktsioonid
    
    private init(callback: ((Bool, ErrorType?) -> Void)?) {
        super.init()
        
        // Jälgi kontekstide salvestumist (et muutusi migreerida)
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { (notification) -> Void in
            if let context = notification.object as? NSManagedObjectContext where context.persistentStoreCoordinator == self.persistentStoreCoordinator {
                self.context.performBlock({ () -> Void in
                    self.context.mergeChangesFromContextDidSaveNotification(notification)
                })
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let response = self.initialize()
            
            if let block = callback {
                dispatch_sync(dispatch_get_main_queue()) {
                    block(response)
                }
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func initialize() -> (Bool, ErrorType?) {
        // Mudel (MOMD)
        let bundle = NSBundle(forClass: self.dynamicType)
        let modelURL = bundle.URLForResource(self.storeName, withExtension: "momd")!
        if let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL) {
            // Koordinator
            let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            let response = self.initializePersistentStore(coordinator)
            if !response.success {
                return response
            }
            
            self.persistentStoreCoordinator = coordinator
            
            // Kontekstid
            let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            mainContext.name = self.mainContextName
            mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
            mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.context = mainContext
            
            return (true, nil)
        } else {
            return (false, Error.InvalidModel)
        }
    }
    
    private func initializePersistentStore(coordinator: NSPersistentStoreCoordinator) -> (success: Bool, error: ErrorType?) {
        // Andmebaasi fail kohalikus dokumentide kaustas
        let url: NSURL = {
            var url = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
            url = url.URLByAppendingPathComponent(self.storeFilename)
            
            return url
        }()
        
        // Lae baas kettalt
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch let error {
            return (false, error)
        }
        
        return (true, nil)
    }
    
    public func save() {
        if !self.context.hasChanges {
            return
        }
        
        self.context.performBlockAndWait() {
            // Viska minema kõik asjad, mis põhjustaksid salvestamisel vea
            var count: Int = 0
            
            for object in self.context.deletedObjects {
                do {
                    try object.validateForDelete()
                } catch let error {
                    print("Deletion error \(error)")
                    
                    count++
                    self.context.refreshObject(object, mergeChanges: false)
                }
            }
            
            print("\(count) objects failed to delete and were reset")
            count = 0

            for object in self.context.updatedObjects {
                do {
                    try object.validateForUpdate()
                } catch let error {
                    print("Update error \(error)")
                    
                    count++
                    self.context.deleteObject(object)
                }
            }
            
            print("\(count) objects failed to update and were deleted")
            count = 0
            
            for object in self.context.insertedObjects {
                do {
                    try object.validateForInsert()
                } catch let error {
                    print("Insertion error \(error)")
                    
                    count++
                    self.context.deleteObject(object)
                }
            }
            
            print("\(count) objects failed to insert and were deleted")
            count = 0
            
            // Salvesta andmebaas
            do {
                try self.context.save()
            } catch let error {
                print("Failed to save \(error)")
            }
        }
    }
    
    /// Kogu olemasoleva andmebaasi kustutamine
    public func deleteAllData() -> Void {
        for persistentStore in self.persistentStoreCoordinator.persistentStores {
            if let url = persistentStore.URL {
                do {
                    try self.persistentStoreCoordinator.removePersistentStore(persistentStore)
                    try NSFileManager.defaultManager().removeItemAtPath(url.path!)
                } catch {
                    
                }
            }
        }
        
        self.initializePersistentStore(self.persistentStoreCoordinator)
    }
    
    /// Ajutisteks muudatusteks, mille salvestamist rakendus soovib täpsemalt
    /// kontrollida saab kasutada eraldi konteksti.
    /// Salvestamise eest vastutab funktsiooni kutsuja, vastasel juhul muudatused ei salvestu
    public func scratchContext(concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // Kui kontekst salvestatakse, siis migreeritakse muutused peamisse konteksti
        return context
    }
}
