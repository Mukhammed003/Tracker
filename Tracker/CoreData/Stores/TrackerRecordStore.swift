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

protocol TrackerRecordStoreDelegate: AnyObject {
    func store(
        _ store: TrackerRecordStore,
        didUpdate: StoreUpdate
    )
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    weak var delegate: TrackerRecordStoreDelegate?
    private var frcDelegate: BaseFetchedResultsControllerDelegate<StoreUpdate>?
    
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
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "tracker.id", ascending: true),
            NSSortDescriptor(key: "date", ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        let delegate = BaseFetchedResultsControllerDelegate<StoreUpdate>(
            ownerName: "TrackerRecordStore"
        ) { [weak self] update in
            guard let self else { return }
            self.delegate?.store(self, didUpdate: update)
        }
        
        controller.delegate = delegate
        frcDelegate = delegate
        fetchedResultController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("⚠️ TrackerRecordStore: performFetch failed: \(error)")
        }
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
    
    func getAllRecords() -> [TrackerRecord] {
        guard let objects = fetchedResultController?.fetchedObjects else { return [] }
        return objects.compactMap { try? trackerRecord(from: $0) }
    }
    
    private func trackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
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
