//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 27.09.2025.
//

import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidHeader
    case decodingErrorInvalidListOfTrackers
}

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<TrackerCategoryStoreUpdate.Move>
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(
        _ store: TrackerCategoryStore,
        didUpdate: TrackerCategoryStoreUpdate
    )
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    private let trackerStore = TrackerStore()
    
    convenience override init() {
        let context: NSManagedObjectContext
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    context = appDelegate.persistentContainer.viewContext
                } else {
                    context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                    print("⚠️ Не удалось получить AppDelegate. Используется fallback context (TrackerCategoryStore)")
                }
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.header, ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        controller.delegate = self
        self.fetchedResultController = controller
        
        do {
            try controller.performFetch()
        }
        catch {
            print("⚠️ TrackerCategoryStore: performFetch failed: \(error)")
        }
    }
    
    var trackerCategories: [TrackerCategory] {
        guard let objects = self.fetchedResultController?.fetchedObjects else { return [] }
        return objects.compactMap { try? self.trackerCategory(from: $0) }
    }
    
    func addNewTrackerCategory(newTracker: Tracker, header: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.header = header
        
        let tracker = trackerStore.addNewTrackerAndReturn(newTracker: newTracker)
        
        category.addToListOfTrackers(tracker)
        saveContext()
        print("Новый трекер добавлен с новой категорией в TrackerCategoryCoreData")
    }
    
    func addToExistingTrackerCategory(newTracker: Tracker, header: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "header == %@", header)
        
        do {
            let records = try context.fetch(request)
            if let needCategory = records.first {
                let tracker = trackerStore.addNewTrackerAndReturn(newTracker: newTracker)
                
                needCategory.addToListOfTrackers(tracker)
                saveContext()
                print("Новый трекер добавлен в существующую категорию в TrackerCategoryCoreData")
            }
        } catch {
            print("Ошибка при добавлении нового трекера в существующую категорию (TrackerCategoryCoreData): \(error)")
        }
    }
    
    func debugPrintAllCategories() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let records = try context.fetch(request)
            print("=== Все записи TrackerCategoryCoreData ===")
            records.forEach { record in
                print("Header: \(record.header ?? "Нет записей"), количество трекеров: \(record.listOfTrackers?.count ?? 0)")
            }
        } catch {
            print("Ошибка при выборке записей (TrackerCategoryCoreData): \(error)")
        }
    }
    
    func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let header = trackerCategoryCoreData.header else {
            throw TrackerCategoryStoreError.decodingErrorInvalidHeader
        }
        
        guard let trackersSet = trackerCategoryCoreData.listOfTrackers as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.decodingErrorInvalidListOfTrackers
        }
        
        let trackers: [Tracker] = try trackersSet.map( { try trackerStore.tracker(from: $0)} )
        
        return TrackerCategory(
            header: header,
            listOfTrackers: trackers)
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes ?? [],
                deletedIndexes: deletedIndexes ?? [],
                updatedIndexes: updatedIndexes ?? [],
                movedIndexes: movedIndexes ?? []
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                if let indexPath = newIndexPath {
                    insertedIndexes?.insert(indexPath.item)
                }
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexes?.insert(indexPath.item)
                }
            case .update:
                if let indexPath = indexPath {
                    updatedIndexes?.insert(indexPath.item)
                }
            case .move:
                if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                    movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
                }
            @unknown default:
                print("⚠️ TrackerCategoryStore: неизвестный NSFetchedResultsChangeType")
            }
    }
}
