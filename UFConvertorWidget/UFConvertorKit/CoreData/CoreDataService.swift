//
//  CoreDataService.swift
//  UFConvertorKit
//
//  Created by Claire on 04/07/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation
import CoreData

//The final keyword doesn't allow us to do subclassing
final class CoreDataService {
    
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
        
        //TODO: hide under feature flag
//        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: nil)
        
        //pass context as object. if nil, it will receive notifications from any context
        let context = coreDataStack.persistentContainer.backgroundManagedContext
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: context)
    }
    
    @objc private func contextDidChange(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print("--- INSERTS ---")
            print(inserts)
            print("+++++++++++++++")
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("--- UPDATES ---")
            for update in updates {
                print(update.changedValues())
            }
            print("+++++++++++++++")
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("--- DELETES ---")
            print(deletes)
            print("+++++++++++++++")
        }
    }
}

extension CoreDataService {
    
    //    NSPredicate(format: "date == %@", date)
    
    //1. is there a serie for today's date ?
    //YES -> uses local data
    //NO -> (2)
    
    //2. is there a serie for yesterday's date ?
    //YES -> server request for today's date (3a)
    //NO -> server request for latest 30 days (3b)
    
    //3a. saves new serie in CoreData
    
    //3b. delete all previous data (to avoid date gaps with no info)
    //save all new data
    
    func fetchSeries(with predicate: NSPredicate?, fetchLimit: Int?) throws -> [Serie] {
        let context = coreDataStack.persistentContainer.backgroundManagedContext
        let fetchRequest = NSFetchRequest<SerieManagedObject>(entityName: "Serie")
        fetchRequest.predicate = predicate
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        let result = try context.fetch(fetchRequest)
        return result.map { Serie(date: $0.date, value: $0.value) }
    }
    
    func save(series: [Serie]) throws {
        let context = coreDataStack.persistentContainer.backgroundManagedContext
        try series.forEach {
            let object = NSEntityDescription.insertNewObject(forEntityName: "Serie",
                                                             into: context) as! SerieManagedObject
            object.date = $0.date
            object.value = $0.value
            try context.save()
        }
    }
    
    func delete() throws {
        let context = coreDataStack.persistentContainer.backgroundManagedContext
        let fetchRequest = NSFetchRequest<SerieManagedObject>(entityName: "Serie")
        let result = try context.fetch(fetchRequest)
        result.forEach {
            context.delete($0)
        }
        try context.save()
    }
}
