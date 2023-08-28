//
//  CategoryService.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/08/27.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class CategoryService {
    
    static let shared = CategoryService()
    
    private init() {}
    
    let uid = Auth.auth().currentUser?.uid
    
    
    
    func fetchCategories() async throws -> [Category] {
        
        guard let uid else { throw FBError.noUserUID }
        
        let categories = try await COLLECTION_USERS.document(uid).collection("categories").getDocuments().documents.map { Category(dictionary: $0.data())}
        
        return categories
        
    }
    
    func fetchCategoriesWithPlaces(_ categories: [Category]) async throws -> [Category] {
        
        guard let uid else { throw FBError.noUserUID }
        
        return try await withThrowingTaskGroup(of: Category.self) { group in
            for category in categories {
                group.addTask {
                    let fetchedPlaces = try await COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").getDocuments().documents
                        .map { FetchedPlace(dictionary: $0.data()) }
                    var newCategory = category
                    newCategory.addedPlaces = fetchedPlaces
                    return newCategory
                }
            }
            
            var result: [Category] = []
            for try await category in group {
                result.append(category)
            }
            
            return result
        }
        
       
    }
    
    func addCategory(with category: Category) async throws {
//        delegate?.updateBeenMade()
        
        guard let uid else { throw FBError.noUserUID }
        
        let documentPath = COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID)
        
        try await documentPath.setData([
            "title": category.title,
            "colorNumber": category.colorNumber,
            "description": category.description,
            "timeStamp": category.timeStamp,
            "categoryUID": category.categoryUID
        ])
        
    }
    
    func getFavoritedCategories(categories: [Category], place: FetchedPlace) async throws -> [Category] {
        
        guard let uid else { throw FBError.noUserUID }
        
        let tuples: [(Category, QuerySnapshot)] = try await withThrowingTaskGroup(of: (Category ,QuerySnapshot).self) { group in
            
            for category in categories {
                
                group.addTask {
                    let documents = (category, try await COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").whereField("placeID", isEqualTo: place.placeID).getDocuments())
                    return documents
                }
            }
            
            var result: [(Category, QuerySnapshot)] = []
            
            
            
            for try await item in group {
                result.append(item)
            }
            
            
            return result
        }
        
        return tuples
               .filter { $0.1.count != 0 }
               .map { $0.0}
            
        
    }
}
