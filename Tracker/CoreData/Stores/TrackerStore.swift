//
//  TrackerStore.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 27.09.2025.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
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
    
}
