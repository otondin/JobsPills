//
//  Sentence+CoreDataProperties.swift
//  ShakeJobs
//
//  Created by Gabriel Tondin on 16/07/16.
//  Copyright © 2016 Caife Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Sentence {

    @NSManaged var text: String?
    @NSManaged var info: String?

}
