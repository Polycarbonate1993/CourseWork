//
//  CoreDataManager.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 26.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataManager {
    private let modelName: String
    
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var container: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores(completionHandler: { _,error in
            if let error = error as NSError? {
                fatalError("Unresilved error \(error), \(error.userInfo)")
            }
        })
        return persistentContainer
    }()
    
    func getContext() -> NSManagedObjectContext {
        let context = container.viewContext
        context.mergePolicy = NSMergePolicy.init(merge: .overwriteMergePolicyType)
        return context
    }
    
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror) \(nserror.userInfo)")
            }
        }
    }
    
    func createObject<T: NSManagedObject> (from entity: T.Type) -> T {
        let context = getContext()
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
        return object
    }
    
    func delete(object: NSManagedObject) {
        let context = getContext()
        context.delete(object)
        save(context: context)
    }
    
    func fetchData<T: NSManagedObject> (for entity: T.Type, predicate: NSCompoundPredicate? = nil) -> [T] {
        let context = getContext()
        let request: NSFetchRequest<T>
        var fetchedResult = [T]()
        request = entity.fetchRequest() as! NSFetchRequest<T>
        request.predicate = predicate
        request.fetchBatchSize = 0
        request.fetchLimit = 100
        if T() is CoreDataPost {
            let sortDescriptor = NSSortDescriptor(key: "createdTime", ascending: false)
            request.sortDescriptors = [sortDescriptor]
        }
        do {
            fetchedResult = try context.fetch(request)
        } catch {
            debugPrint("Couldn't fetch: \(error.localizedDescription)")
        }
        return fetchedResult
    }
    
    func changeObject<T: NSManagedObject>(object: T, changedProperties: [String: Any]) {
        let context = getContext()
        for (key, value) in changedProperties {
            object.setValue(value, forKey: key)
        }
        save(context: context)
    }
}
