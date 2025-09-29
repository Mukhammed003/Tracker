//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 27.09.2025.
//

import UIKit
import CoreData

final class TrackerRecordStore {
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
                print("ID: \(record.tracker?.id ?? -1), date: \(record.date ?? Date())")
            }
        } catch {
            print("Ошибка при выборке записей (TrackerRecordCoreData): \(error)")
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
