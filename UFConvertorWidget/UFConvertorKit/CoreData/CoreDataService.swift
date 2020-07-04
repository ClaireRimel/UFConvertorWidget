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

        //Using dependency injection via initializer allows us to
        //1. provide as a default argument the value we want to use in our production code
        //2. possibility to pass a different object as a parameter that can act as a mock for testing purposes
        init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
            self.coreDataStack = coreDataStack
        }
}

extension CoreDataService {
    
    func fetchSeries() -> Result<[Serie], Error> {
        let managedContext = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SerieEntity")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            print("Fetch Result")
            print(result)
            let series = result.map {
                //All Serie properties are non-optional, so we can assume there will be data stored for each of its properties
                Serie(date: $0.value(forKey: "date") as! String,
                      value: $0.value(forKey: "value") as! Double)
            }
            
            print("Fetch Result - SERIES")
            print(series)
            return .success(series)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return .failure(error)
        }
    }
    
    func fetchSerie(for date: String) -> Result<Bool, Error> {
        let managedContext = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SerieEntity")
        fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            return .success(result.count == 1)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return .failure(error)
        }
    }
}
