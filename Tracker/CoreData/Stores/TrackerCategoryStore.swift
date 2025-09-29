//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 27.09.2025.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    private let trackerStore = TrackerStore()
    
    convenience init() {
        let context: NSManagedObjectContext
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    context = appDelegate.persistentContainer.viewContext
                } else {
                    context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                    print("⚠️ Не удалось получить AppDelegate. Используется fallback context")
                }
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
                print("Header: \(record.header ?? "Нет записей")")
            }
        } catch {
            print("Ошибка при выборке записей (TrackerCategoryCoreData): \(error)")
        }
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
