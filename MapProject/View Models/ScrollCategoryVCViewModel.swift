//
//  ScrollCategoryVCViewModel.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/02.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol ScrollCategoryVCListViewModelDelegate: AnyObject {
    func ScrollCategoryVCListViewModelUpdated(snapshot: NSDiffableDataSourceSnapshot<Section, Category>)
}

class ScrollCategoryVCListViewModel {
    
    var shouldUpdate: Bool = false
    
    var snapshot: NSDiffableDataSourceSnapshot<Section, Category>!
    
    weak var delegate: ScrollCategoryVCListViewModelDelegate?
    
    var categories: [Category] = [] {
        didSet {
            
            delegate?.ScrollCategoryVCListViewModelUpdated(snapshot: snapshot)
            shouldUpdate = false
        }
    }
    
    var numberOfRows: Int {
        return self.categories.count + 1
    }
    
    init() {
        FavoriteSerivce.shared.delegate = self
        updateCategories()
    }
    
    func getCategoryAtIndex(_ index: Int) -> Category {
        return categories [ index - 1]
    }
    
    func getCategoryViewModelAtIndex(_ index: Int) -> ScrollCategoryVCViewModel  {
        let category = self.categories[ index - 1]
        return ScrollCategoryVCViewModel(category: category)
    }
    
    func updateCategories() {
        fetchcategories { categories in
            self.fetchFavoritePlaces(categories: categories) { categories in
                self.categories = categories
            }
        }

    }
    
    private func fetchcategories(completion: @escaping ([Category]) -> Void) {
        
        FavoriteSerivce.shared.fetchCategories { categories in
            
            completion(categories)
        }
    }
    
    private func fetchFavoritePlaces(categories: [Category], completion: @escaping ([Category]) -> Void) {
        
//        var categoriesWithPlaces: [Category] = []
        var categoriesWithPlaces: [Category] = [Category(title: "Mock", colorNumber: 0, description: "Mock", timeStamp: Timestamp(date: Date().pastDate()))]
        let group = DispatchGroup()
        for category in categories {
            group.enter()
            FavoriteSerivce.shared.fetchFavorite(category: category) { result in
                defer { group.leave() }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let places):
                    var newCategory = category
                    newCategory.addedPlaces = places
                    categoriesWithPlaces.append(newCategory)
                }
                
            }
        }
        group.notify(queue: .main) {
            var snapshot = NSDiffableDataSourceSnapshot<Section, Category>()
            snapshot.appendSections([.main])
            snapshot.appendItems(categoriesWithPlaces.sorted(by: { $0.timeStamp.dateValue() < $1.timeStamp.dateValue()}))
            self.snapshot = snapshot
            completion(categoriesWithPlaces)
            print(categoriesWithPlaces.count)
        }
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
            updateCategories()
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
