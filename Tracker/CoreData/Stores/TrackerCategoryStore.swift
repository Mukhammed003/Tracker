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
    private let trackerRecordStore = TrackerRecordStore()
    
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
        debugPrintAllCategories()
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
                debugPrintAllCategories()
                trackerStore.debugPrintAllTrackers()
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
    
    func deleteTrackerInSuchCategory(trackerId: Int64, header: String) {
        
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "header == %@", header)
        
        do {
            let records = try context.fetch(request)
            if let needCategory = records.first,
               let trackers = needCategory.listOfTrackers as? Set<TrackerCoreData>,
               let trackerToDelete = trackers.first(where: { $0.id == trackerId }) {
                
                needCategory.removeFromListOfTrackers(trackerToDelete)
                context.delete(trackerToDelete)
                saveContext()
                
                print("Трекер с id: \(trackerId) удалён из TrackerCategoryCoreData")
                debugPrintAllCategories()
                trackerStore.debugPrintAllTrackers()
            }
        }
        catch {
            print("Ошибка при удалении трекера из TrackerCategoryCoreData: \(error)")
        }
        
    }
    
    func updateTrackerInSuchCategory(categoryName: String, tracker: Tracker, oldCategoryName: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "header == %@", categoryName)
        
        do {
            guard let category = try context.fetch(request).first else {
                print("❌ Категория \(categoryName) не найдена")
                return
            }
            
            if let trackers = category.listOfTrackers as? Set<TrackerCoreData>,
               let existingTracker = trackers.first(where: { $0.id == tracker.id }) {
                
                existingTracker.name = tracker.name
                existingTracker.emoji = tracker.emoji
                existingTracker.color = tracker.color
                if let schedule = tracker.schedule {
                    existingTracker.schedule = schedule as NSArray
                } else {
                    existingTracker.schedule = nil
                }
                print("✅ Трекер с id \(tracker.id) обновлён в категории \(categoryName)")
                debugPrintAllCategories()
                trackerStore.debugPrintAllTrackers()
            } else {
                // 2️⃣ Находим старую категорию и трекер
                let oldRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                oldRequest.predicate = NSPredicate(format: "header == %@", oldCategoryName)
                
                guard let oldCategory = try context.fetch(oldRequest).first,
                      let oldTrackers = oldCategory.listOfTrackers as? Set<TrackerCoreData>,
                      let oldTracker = oldTrackers.first(where: { $0.id == tracker.id }) else {
                    print("❌ Старый трекер не найден")
                    return
                }
                
                // 3️⃣ Создаём новый трекер в новой категории
                let newTrackerCD = TrackerCoreData(context: context)
                newTrackerCD.id = Int64(tracker.id)
                newTrackerCD.name = tracker.name
                newTrackerCD.emoji = tracker.emoji
                newTrackerCD.color = tracker.color
                newTrackerCD.schedule = tracker.schedule as? NSArray
                
                category.addToListOfTrackers(newTrackerCD)
                
                // 4️⃣ Переносим все записи TrackerRecordCoreData
                if let records = oldTracker.record as? Set<TrackerRecordCoreData> {
                    for record in records {
                        record.tracker = newTrackerCD
                    }
                    print("📦 Перенесено \(records.count) записей в новый трекер")
                }
                
                // 5️⃣ Удаляем старый трекер
                context.delete(oldTracker)
                
                print("♻️ Трекер перенесён из категории '\(oldCategoryName)' в '\(categoryName)'")
            }
            
            saveContext()
            debugPrintAllCategories()
            trackerStore.debugPrintAllTrackers()
            
        } catch {
            print("❌ Ошибка при обновлении трекера в категории \(categoryName): \(error)")
        }
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
