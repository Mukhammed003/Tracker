//
//  TrackerStore.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 27.09.2025.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidschedule
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TrackerCoreData>?
    
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    convenience override init() {
        let context: NSManagedObjectContext
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
        } else {
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            print("⚠️ Не удалось получить AppDelegate. Используется fallback context (TrackerStore)")
        }
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)
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
            }
        catch {
                print("⚠️ TrackerStore: performFetch failed: \(error)")
            }
    }
    
    var trackers: [Tracker] {
        guard let objects = self.fetchedResultController?.fetchedObjects else { return [] }
        return objects.compactMap { try? self.tracker(from: $0) }
    }
    
    func fetchTrackerById(_ id: Int64) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Ошибка поиска трекера в TrackerCoreData: \(error)")
            return nil
        }
    }
    
    func addNewTrackerAndReturn(newTracker: Tracker) -> TrackerCoreData {
        
        let tracker = TrackerCoreData(context: context)
        tracker.id = Int64(newTracker.id)
        tracker.name = newTracker.name
        tracker.color = newTracker.color
        tracker.emoji = newTracker.emoji
        tracker.setValue(newTracker.schedule as Any, forKey: "schedule")
        
        print("Новый трекер добавлен в TrackerCoreData")
        
        return tracker
    }
    
    func debugPrintAllTrackers() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let trackers = try context.fetch(request)
            print("=== Все записи с TrackerCoreData ===")
            trackers.forEach { tracker in
                print("ID: \(tracker.id), name: \(tracker.name ?? "nil")")
            }
        } catch {
            print("Ошибка при выборке трекеров (TrackerCoreData): \(error)")
        }
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let color = trackerCoreData.color as? UIColor else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let schedule = trackerCoreData.schedule as? [DaysOfWeek] else {
            throw TrackerStoreError.decodingErrorInvalidschedule
        }
        
        return Tracker(
            id: UInt(trackerCoreData.id),
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
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
        newIndexPath: IndexPath?
    ) {
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
            print("⚠️ TrackerStore: неизвестный NSFetchedResultsChangeType")
        }
    }
}
