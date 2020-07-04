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
    
    
}
