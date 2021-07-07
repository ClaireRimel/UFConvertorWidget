//
//  SerieManagedObject.swift
//  UFConvertorKit
//
//  Created by Claire Sivadier on 04/07/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation
import CoreData

@objc(SerieManagedObject)
final class SerieManagedObject: NSManagedObject {
    
    @NSManaged var date: String
    @NSManaged var value: Double
}
