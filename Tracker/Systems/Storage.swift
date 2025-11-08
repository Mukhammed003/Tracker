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
    }
    
    // MARK: - API
    func saveSelectedFilter(index: Int) {
        UserDefaults.standard.set(index, forKey: Constants.selectedFilterIndex)
    }
    
    func loadSelectedFilter() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.selectedFilterIndex)
    }
    
    func clearSelectedFilter() {
        UserDefaults.standard.removeObject(forKey: Constants.selectedFilterIndex)
    }
}
