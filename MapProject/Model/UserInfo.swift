//
//  UserCategory.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/23.
//

import Foundation

class UserInfo {
    let categoryChangedIdentifier = "categoryChanged"
    
    static let shared = UserInfo()
    
    private init() {}
    
    private var _categories: [Category] = [] {
        didSet {
            let name = Notification.Name(categoryChangedIdentifier)
            NotificationCenter.default.post(name: name, object: nil)
            print(_categories)
        }
    }
    
    var categories: [Category] {
        
        get { return _categories }
        
        set {
            _categories = newValue.sorted(by: { $0.timeStamp.dateValue() > $1.timeStamp.dateValue()})
        }
    }
    
    var addedCategories: [Category] = []
    
    var user: User!
}
