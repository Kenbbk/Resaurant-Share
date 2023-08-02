//
//  ScrollCategoryVCViewModel.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/02.
//

import Foundation

class ScrollCategoryVCListViewModel {
    
    var categories: [Category]
    
    init(categories: [Category]) {
        self.categories = categories
    }
    
    var numberOfRows: Int {
        return self.categories.count + 1
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
    
    init(category: Category) {
        self.category = category
    }
    
    

}
