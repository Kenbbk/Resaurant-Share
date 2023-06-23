//
//  UserCategory.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/23.
//

import Foundation

class UserCategory {
    static let shared = UserCategory()
    
    private init() {}
    
    private var _userCategories: [Category] = []
    
    var userCategories: [Category] {
        
        get { return _userCategories }
        
        set {
            _userCategories = newValue.sorted(by: { $0.timeStamp.dateValue() > $1.timeStamp.dateValue()})
        }
    }
    
    var user: User!
}
