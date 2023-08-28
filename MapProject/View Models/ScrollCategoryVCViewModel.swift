//
//  ScrollCategoryVCViewModel.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/02.
//

import Foundation

import FirebaseFirestore

protocol ScrollCategoryVCListViewModelDelegate: AnyObject {
    func ScrollCategoryVCListViewModelUpdated(categoryModels: [CategoryModel])
}

class ScrollCategoryVCListViewModel {
    
    var shouldUpdate: Bool = false
    
    var snapshot: NSDiffableDataSourceSnapshot<Section, Category>!
    
    weak var delegate: ScrollCategoryVCListViewModelDelegate?
    
    var categories: [Category] = [] {
        didSet {
            
            
        }
    }
    
    var numberOfRows: Int {
        return self.categories.count + 1
    }
    
    init() {
        FavoriteSerivce.shared.delegate = self
        Task {
            await updateCategories()
        }
        
    }
    
    func getCategoryAtIndex(_ index: Int) -> Category {
        return categories [ index]
    }
    
    func getCategoryViewModelAtIndex(_ index: Int) -> ScrollCategoryVCViewModel  {
        let category = self.categories[index]
        return ScrollCategoryVCViewModel(category: category)
    }
    
    //    func updateCategories() {
    //        fetchcategories { categories in
    //            self.fetchFavoritePlaces(categories: categories) { [weak self] categories in
    //                guard let self else { return }
    //                self.categories = categories
    //                let categoryModels = self.makeCategoryModel(categories: categories)
    //                self.delegate?.ScrollCategoryVCListViewModelUpdated(categoryModels: categoryModels)
    //                self.shouldUpdate = false
    //            }
    //        }
    //
    //    }
    
    func updateCategories() async {
        do {
            let tempCategories = try await fetchcategories()
            self.categories = try await fetchFavoritePlaces(from: tempCategories)
            let categoryModels = self.makeCategoryModel(categories: categories)
            self.delegate?.ScrollCategoryVCListViewModelUpdated(categoryModels: categoryModels)
            self.shouldUpdate = false
            
        } catch {
            print(error)
            
            
        }
    }
    
    
    
    
    //    private func fetchcategories(completion: @escaping ([Category]) -> Void) {
    //
    //        FavoriteSerivce.shared.fetchCategories { categories in
    //
    //            completion(categories)
    //        }
    //    }
    
    private func fetchcategories() async throws -> [Category] {
        
        let categories = try await CategoryService.shared.fetchCategories()
        self.categories = categories
        return categories
        
    }
    
    private func fetchFavoritePlaces(from categories: [Category]) async throws -> [Category]  {
        
        return try await CategoryService.shared.fetchCategoriesWithPlaces(categories)
        
    }
    
    
    private func makeCategoryModel(categories: [Category]) -> [CategoryModel] {
        let categoryModels = categories.map({ CategoryModel(title: $0.title, colorNumber: $0.colorNumber, description: $0.description, categoryUID: $0.categoryUID)})
        return categoryModels
    }
}

extension ScrollCategoryVCListViewModel: FavoriteServiceDelegate {
    func updateBeenMade() {
        shouldUpdate = true
    }
    
    
}

extension ScrollCategoryVCListViewModel: CategoryScrollableViewDelegate {
    func categoryScrollableViewHiddenStateChanged() {
        if shouldUpdate {
            Task {
                await updateCategories()
            }
            
        }
    }
    
    
    
    
}

struct ScrollCategoryVCViewModel {
    
    var category: Category
    
    var categoryName: String {
        return category.title
    }
    
    var colorNumber: Int {
        return category.colorNumber
    }
    
    var addedPlaceNumber: String {
        return "\(category.addedPlaces.count)"
    }
    
    init(category: Category) {
        self.category = category
    }
    
    
    
}
