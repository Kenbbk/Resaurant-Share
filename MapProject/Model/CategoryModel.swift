//
//  CategoryModel.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/04.
//

import Foundation

struct CategoryModel: Equatable, Hashable {
    static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        return lhs.categoryUID == rhs.categoryUID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(categoryUID)
    }
    
    let title: String
    let colorNumber: Int
    let description: String
    let categoryUID: String
    let addedPlaces: [FetchedPlace] = []
}
