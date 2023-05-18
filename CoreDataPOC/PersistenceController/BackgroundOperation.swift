//
//  BackgroundOperation.swift
//  CoreDataPOC
//
//  Created by Andrei Botoaca on 07.05.23.
//

import CoreData

protocol BackgroundOperation {
    func execute(context: NSManagedObjectContext)
}

