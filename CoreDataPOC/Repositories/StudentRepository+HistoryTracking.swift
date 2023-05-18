//
//  StudentRepository+HistoryTracking.swift
//  CoreDataPOC
//
//  Created by Andrei Botoaca on 15.05.23.
//

import UIKit
import CoreData

extension StudentRepository {
    class HistoryTracking: BackgroundOperation {
        private var lastToken: LastToken
        
        private var viewContext: NSManagedObjectContext
        
        init(lastToken: LastToken, viewContext: NSManagedObjectContext) {
            self.lastToken = lastToken
            self.viewContext = viewContext
        }
        
        func execute(context: NSManagedObjectContext) {
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastToken.getLastToken())
            do {
                let historyResult = try context.execute(changeRequest) as? NSPersistentHistoryResult
                if let history = historyResult?.result as? [NSPersistentHistoryTransaction], !history.isEmpty {
                    viewContext.perform {
                        for transaction in history {
                            self.viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                            self.lastToken.updateLastToken(lastToken: transaction.token)
                        }
                    }
                }
            }
            catch {
                print("Error processing history results: \(error.localizedDescription)")
            }
        }
    }
}
