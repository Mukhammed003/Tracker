//
//  Storage.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 08.11.2025.
//

import Foundation

final class Storage {
    
    // MARK: - Singleton (одиночка)
    static let shared = Storage()
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let bestPeriodValue = "bestPeriodValue"
        static let perfectDaysValue = "perfectDaysValue"
        static let completedTrackersValue = "completedTrackersValue"
        static let averageValue = "averageValue"
    }
    
    // MARK: - API
    
    // Selected Filter
    
    func saveSelectedFilter(index: Int) {
        UserDefaults.standard.set(index, forKey: Constants.selectedFilterIndex)
    }
    
    func loadSelectedFilter() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.selectedFilterIndex)
    }
    
    func clearSelectedFilter() {
        UserDefaults.standard.removeObject(forKey: Constants.selectedFilterIndex)
    }
    
    // Values for statistics
    
    func saveValuesForStatistics(bestPeriodValue: Double, perfectDaysValue: Double, completedTrackersValue: Double, averageValue: Double) {
        UserDefaults.standard.set(bestPeriodValue, forKey: Keys.bestPeriodValue)
        UserDefaults.standard.set(perfectDaysValue, forKey: Keys.perfectDaysValue)
        UserDefaults.standard.set(completedTrackersValue, forKey: Keys.completedTrackersValue)
        UserDefaults.standard.set(averageValue, forKey: Keys.averageValue)
    }
    
    func loadBestPeriodValue() -> Double {
        return UserDefaults.standard.double(forKey: Keys.bestPeriodValue)
    }
    
    func loadPerfectDaysValue() -> Double {
        return UserDefaults.standard.double(forKey: Keys.perfectDaysValue)
    }
    
    func loadCompletedTrackersValue() -> Double {
        return UserDefaults.standard.double(forKey: Keys.completedTrackersValue)
    }
    
    func loadAverageValue() -> Double {
        return UserDefaults.standard.double(forKey: Keys.averageValue)
    }
}
