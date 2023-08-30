//
//  CategoryCellModel.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/29.
//

import Foundation

struct CategoryCellModel: Equatable,Hashable {
    let title: String
    let colorNumber: Int
    let categoryUID: String
    var shouldHighLighted: Bool
    
    static func == (lhs: CategoryCellModel, rhs: CategoryCellModel) -> Bool {
        return lhs.categoryUID == rhs.categoryUID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(categoryUID)
    }
}
