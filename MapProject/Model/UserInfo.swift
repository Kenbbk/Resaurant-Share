//
//  UserCategory.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/23.
//

import Foundation
import FirebaseAuth

class UserInfo {
    let categoryChangedIdentifier = "categoryChanged"
    
    let userID = Auth.auth().currentUser?.uid
    
    static let shared = UserInfo()
    
    private init() { }
    
    private var _categories: [Category] = [] {
        didSet {
            

            NotificationCenter.default.post(name: Notification.Name.userInfoCategoriesChanged, object: nil)
            
        }
    }
    
    var categories: [Category] {
        
        get { return _categories }
        
        set {
            _categories = newValue.sorted(by: { $0.timeStamp.dateValue() > $1.timeStamp.dateValue()})
        }
    }
    
    var addedCategories: [Category] = []
    
    
}
