//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 25.10.2025.
//

final class CategoryViewModel {
    
    var selectedCategoryIndex: Int?
    var onCategoriesChanged: (() -> Void)?
    
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = []
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        loadCategories()
    }
    
    func loadCategories() {
        categories = categoryStore.getAllCategories()
        onCategoriesChanged?()
    }
    
    func addCategory(_ name: String) {
        categoryStore.addNewCategory(header: name)
        loadCategories()
    }
    
    func selectCategory(at index: Int) {
        selectedCategoryIndex = index
    }
    
    func selectedCategoryName() -> String? {
        guard let index = selectedCategoryIndex else { return nil }
        return categories[index].header
    }
    
    func deleteCategory(header: String) {
        categoryStore.deleteCategory(withHeader: header)
        loadCategories()
    }
    
    func updateCategory(oldHeader: String, newHeader: String) {
        categoryStore.updateCategory(oldHeader: oldHeader, newHeader: newHeader)
        loadCategories()
    }
}
