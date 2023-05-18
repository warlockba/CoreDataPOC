//
//  StudentRepository.swift
//  CoreDataPOC
//
//  Created by Andrei Botoaca on 07.05.23.
//

import UIKit
import CoreData

protocol LastToken {
    func getLastToken() -> NSPersistentHistoryToken?
    func updateLastToken(lastToken: NSPersistentHistoryToken?)
}

class StudentRepository {
    private let persistenceController = (UIApplication.shared.delegate as! AppDelegate).persistenceController
    
    private var notificationToken: NSObjectProtocol?
    
    private var lastToken: NSPersistentHistoryToken?
    
    var fetchedResultsController: NSFetchedResultsController<Student>
    
    private var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    func addStudent(name: String, date: Date, completion: @escaping (Error?) -> Void) {
        let addStudent = AddStudent(name: name, date: date, completion: completion)
        
        persistenceController.performInBackground(operation: addStudent)
    }
    
    func deleteStudent(student: Student, completion: @escaping (Error?) -> Void) {
        let deleteStudent = DeleteStudent(objectID: student.objectID, completion: completion)
        
        persistenceController.performInBackground(operation: deleteStudent)
    }
    
    func test_rePerformFetch() {
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            print("Error fetching students: \(error.localizedDescription)")
        }
    }
    
    init(fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let fetchRequest = Student.fetchRequest()
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        fetchRequest.fetchBatchSize = 40
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistenceController.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = fetchedResultsControllerDelegate
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            print("Error fetching students: \(error.localizedDescription)")
        }
        
//        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
//            print("Received a persistent store remote change notification.")
//
//            let historyTracking = HistoryTracking(lastToken: self, viewContext: self.persistenceController.container.viewContext)
//
//            self.persistenceController.performInBackground(operation: historyTracking)
//        }
    }
    
    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
//    func fetchPersistentHistory() async {
//        do {
//            try await fetchPersistentHistoryTransactionsAndChanges()
//        } catch {
//            print("\(error.localizedDescription)")
//        }
//    }
//
//    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
//        let taskContext = newTaskContext()
//        taskContext.name = "persistentHistoryContext"
//        logger.debug("Start fetching persistent history changes from the store...")
//
//        try await taskContext.perform {
//            // Execute the persistent history change since the last transaction.
//            /// - Tag: fetchHistory
//            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
//            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
//            if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
//               !history.isEmpty {
//                self.mergePersistentHistoryChanges(from: history)
//                return
//            }
//
//            self.logger.debug("No persistent history transactions found.")
//            throw QuakeError.persistentHistoryChangeError
//        }
//
//        logger.debug("Finished merging history changes.")
//    }
//
//    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
//        self.logger.debug("Received \(history.count) persistent history transactions.")
//        // Update view context with objectIDs from history change request.
//        /// - Tag: mergeChanges
//        let viewContext = container.viewContext
//        viewContext.perform {
//            for transaction in history {
//                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
//                self.lastToken = transaction.token
//            }
//        }
//    }
}

extension StudentRepository: LastToken {
    func getLastToken() -> NSPersistentHistoryToken? {
        return self.lastToken
    }
    func updateLastToken(lastToken: NSPersistentHistoryToken?) {
        self.lastToken = lastToken
    }
}
