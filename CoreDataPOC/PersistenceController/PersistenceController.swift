//
//  PersistenceController.swift
//  CoreDataPOC
//
//  Created by Andrei Botoaca on 07.05.23.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    private init() {}
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModelPOC")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // is it really bad?
        container.viewContext.automaticallyMergesChangesFromParent = true
        // does not change the bad things: container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var backgroundQueue = DispatchQueue(label: "com.PanTurtle.CoreDataPOC.backgroundQueue", qos: .userInitiated)
    
    func saveData() {
        container.performBackgroundTask { context in
            self.backgroundQueue.async {
                do {
                    try context.save()
                }
                catch {
                    print("Error updating or deleting entities: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func performInBackground(operation: BackgroundOperation) {
        container.performBackgroundTask { context in
            self.backgroundQueue.async {
                operation.execute(context: context)
            }
        }
    }
}
