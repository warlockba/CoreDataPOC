//
//  StudentRepository+AddStudent.swift
//  CoreDataPOC
//
//  Created by Andrei Botoaca on 07.05.23.
//

import UIKit
import CoreData

extension StudentRepository {
    class AddStudent: BackgroundOperation {
        var name: String
        var date: Date
        var completion: (Error?) -> Void
        
        init(name: String, date: Date, completion: @escaping (Error?) -> Void) {
            self.name = name
            self.date = date
            self.completion = completion
        }
        
        func execute(context: NSManagedObjectContext) {
            do {
                let newStudent = Student(context: context)
                
                newStudent.name = name
                newStudent.date = date
                
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
