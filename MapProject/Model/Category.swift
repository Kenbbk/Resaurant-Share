//
//  Category.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/21.
//

import UIKit
import FirebaseFirestore

struct Category: Equatable, Hashable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.categoryUID == rhs.categoryUID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(categoryUID)
    }
    
    let title: String
    let colorNumber: Int
    let description: String
    let timeStamp: Timestamp
    var categoryUID: String
    var addedPlaces: [FetchedPlace] = []
    
    
    init(title: String, colorNumber: Int, description: String, timeStamp: Timestamp) {
        self.title          = title
        self.colorNumber    = colorNumber
        self.description    = description
        self.timeStamp      = timeStamp
        self.categoryUID    = UUID().uuidString
    }
    
    init(dictionary: [String: Any]) {
        self.title          = dictionary["title"] as? String ?? ""
        self.colorNumber    = dictionary["colorNumber"] as? Int ?? 0
        self.description    = dictionary["description"] as? String ?? ""
        self.timeStamp      = dictionary["timeStamp"] as? Timestamp ?? Timestamp(date: Date())
        self.categoryUID    = dictionary["categoryUID"] as? String ?? ""
    }
}
