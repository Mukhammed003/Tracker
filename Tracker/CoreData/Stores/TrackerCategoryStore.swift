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

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(
        _ store: TrackerCategoryStore,
        didUpdate: StoreUpdate
    )
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    private var frcDelegate: BaseFetchedResultsControllerDelegate<StoreUpdate>?
    
    private let trackerStore = TrackerStore()
    
    convenience override init() {
        let context: NSManagedObjectContext
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
        } else {
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            print("⚠️ Не удалось получить AppDelegate. Используется fallback context (TrackerCategoryStore)") }
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
            cacheName: nil
        )
        
        let delegate = BaseFetchedResultsControllerDelegate<StoreUpdate>(
            ownerName: "TrackerCategoryStore"
        ) { [weak self] update in
            guard let self else { return }
            self.delegate?.store(self, didUpdate: update)
        }
        
        controller.delegate = delegate
        frcDelegate = delegate
        fetchedResultController = controller
        
        do {
            try controller.performFetch()
        }
        catch {
            print("⚠️ TrackerCategoryStore: performFetch failed: \(error)")
        }
    }
    
    func addNewCategory(header: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.header = header
        saveContext()
        print("Добавлена новая категория в TrackerCategoryCoreData")
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
    
    func getAllCategories() -> [TrackerCategory] {
        guard let objects = fetchedResultController?.fetchedObjects else { return [] }
        return objects.compactMap { try? trackerCategory(from: $0) }
    }
    
    func isExistsSuchCategory(withHeader header: String) -> Bool {
        guard let objects = fetchedResultController?.fetchedObjects else { return false }
        
        return objects.contains(where: { $0.header == header })
    }
    
    func isExistsSuchTrackerInCategory(withHeader header: String, withTracker trackerName: String) -> Bool {
        guard let categories = fetchedResultController?.fetchedObjects else { return false }

        guard let category = categories.first(where: { $0.header == header }),
              let trackers = category.listOfTrackers as? Set<TrackerCoreData> else {
            return false
        }

        return trackers.contains { $0.name == trackerName }
    }
    
    private func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let header = trackerCategoryCoreData.header else {
            throw TrackerCategoryStoreError.decodingErrorInvalidHeader
        }
        
        guard let trackersSet = trackerCategoryCoreData.listOfTrackers as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.decodingErrorInvalidListOfTrackers
        }
        
        let trackers: [Tracker] = try trackersSet.map { try trackerStore.tracker(from: $0)} 
        
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
