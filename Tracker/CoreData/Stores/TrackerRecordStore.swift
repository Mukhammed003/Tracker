//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 27.09.2025.
//

import UIKit
import CoreData

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidDate
    case decodingErrorInvalidTracker
}

struct TrackerRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<TrackerRecordStoreUpdate.Move>
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func store(
        _ store: TrackerRecordStore,
        didUpdate: TrackerRecordStoreUpdate
    )
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    weak var delegate: TrackerRecordStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdate.Move>?
    
    convenience override init() {
        let context: NSManagedObjectContext
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
        } else {
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            print("⚠️ Не удалось получить AppDelegate. Используется fallback context (TrackerRecordStore)")
        }
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        controller.delegate = self
        self.fetchedResultController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("⚠️ TrackerRecordStore: performFetch failed: \(error)")
        }
    }
    
    var trackerRecords: [TrackerRecord] {
        guard let objects = self.fetchedResultController?.fetchedObjects else { return [] }
        return objects.compactMap { try? self.trackerRecord(from: $0)}
    }
    
    func addNewTrackerRecord(tracker: TrackerCoreData, date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.tracker = tracker
        saveContext()
        print("Запись была добавлена в TrackerRecordCoreData")
    }
    
    func deleteTrackerRecordByIdAndDate(_ id: Int64, date: Date) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %d AND date == %@", id, date as NSDate)
        
        do {
            let records = try context.fetch(request)
            if let recordToDelete = records.first {
                context.delete(recordToDelete)
                saveContext()
                print("Запись была удалена с TrackerRecordCoreData")
            } else {
                print("Запись не найдена в TrackerRecordCoreData")
            }
        } catch {
            print("Что то пошло не так во время удаления из TrackerRecordCoreData: \(error)")
        }
    }
    
    func debugPrintAllRecords() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let records = try context.fetch(request)
            print("=== Все записи TrackerRecordCoreData ===")
            records.forEach { record in
                print("ID: \(record.tracker?.id ?? -1), date: \(String(describing: record.date))")
            }
        } catch {
            print("Ошибка при выборке записей (TrackerRecordCoreData): \(error)")
        }
    }
    
    func trackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let tracker = trackerRecordCoreData.tracker else {
            throw TrackerRecordStoreError.decodingErrorInvalidTracker
        }
        guard let date = trackerRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidDate
        }
        
        return TrackerRecord(
            id: UInt(tracker.id),
            date: date)
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

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerRecordStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerRecordStoreUpdate(
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
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
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
                print("⚠️ TrackerRecordStore: неизвестный NSFetchedResultsChangeType")
            }
    }
}
