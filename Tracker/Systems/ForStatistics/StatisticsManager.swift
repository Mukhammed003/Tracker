//
//  StatisticsManager.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 11.11.2025.
//

final class StatisticsManager {
    
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let calculator = StatisticsCalculator()
    
    init(categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore
    }
    
    func recalculateStatistics() {
        let categories = categoryStore.getAllCategories()
        let completedTrackers = Set(recordStore.getAllRecords())
        
        calculator.calculateEverythingAndSendToUserDefaults(
            categories: categories,
            completedTrackers: completedTrackers
        )
    }
    
}
