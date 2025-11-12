//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 11.11.2025.
//

enum Mode {
    case create
    case edit(oldHeader: String)
}

protocol NewCategoryViewModelProtocol {
    var oldCategoryName: String? { get set }
    var mode: Mode { get }
    
    func isCategoryExists(_ name: String) -> Bool
    func saveCategory(_ name: String)
}

final class NewCategoryViewModel: NewCategoryViewModelProtocol {
    var oldCategoryName: String?
    
    let mode: Mode
    private let categoryStore: TrackerCategoryStore
    
    init(categoryStore: TrackerCategoryStore, mode: Mode) {
        self.categoryStore = categoryStore
        self.mode = mode
        
        switch mode {
        case .create:
            break
        case .edit(let oldHeader):
            oldCategoryName = oldHeader
        }
    }
    
    func isCategoryExists(_ name: String) -> Bool {
        switch mode {
        case .edit:
            if name == oldCategoryName { return false }
            return categoryStore.isExistsSuchCategory(withHeader: name)
        case .create:
            return categoryStore.isExistsSuchCategory(withHeader: name)
        }
    }
    
    func saveCategory(_ name: String) {
        switch mode {
        case .create:
            categoryStore.addNewCategory(header: name)
        case .edit(let oldHeader):
            categoryStore.updateCategory(oldHeader: oldHeader, newHeader: name)
        }
    }
}
