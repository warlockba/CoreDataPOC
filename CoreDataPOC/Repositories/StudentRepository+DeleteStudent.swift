//
//  StudentRepository+DeleteStudent.swift
//  CoreDataPOC
//
//  Created by Andrei Botoaca on 08.05.23.
//

import UIKit
import CoreData

extension StudentRepository {
    class DeleteStudent: BackgroundOperation {
        var objectID: NSManagedObjectID
        var completion: (Error?) -> Void
        
        init(objectID: NSManagedObjectID, completion: @escaping (Error?) -> Void) {
            self.objectID = objectID
            self.completion = completion
        }
        
        func execute(context: NSManagedObjectContext) {
            do {
                let deleteStudent = try context.existingObject(with: objectID)
                context.delete(deleteStudent)
                try context.save()
                
                DispatchQueue.main.async {
                    self.completion(nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.completion(error)
                }
            }
        }
    }
}
