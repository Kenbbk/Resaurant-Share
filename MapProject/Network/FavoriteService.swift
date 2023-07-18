//
//  FavoriteService.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

let COLLECTION_USERS = Firestore.firestore().collection("users")

class FavoriteSerivce {
    
    var isEdited: Bool = false
    
    enum FavoriteError: Error {
        case noCurrentUser
        case noDocuemnt
    }
    
    static let shared = FavoriteSerivce()
    
    private init() {}
    
    let uid = Auth.auth().currentUser?.uid
    
    func fetchCategories(completion: @escaping ([Category]) -> Void ) {
        
        guard let uid else { return }
        
        COLLECTION_USERS.document(uid).collection("categories").getDocuments { snapShot, error in
            
            guard let documents = snapShot?.documents else { return }
            
            let categories = documents.map( { Category(dictionary: $0.data())})
            
            let sortedCategories = categories.sorted { $0.timeStamp.dateValue() >  $1.timeStamp.dateValue()}
            
            completion(sortedCategories)
        }
    }
    
    func addCategory(with category: Category, completion: @escaping () -> Void) {
        isEdited = true
        guard let uid else { return }
        
        let documentPath = COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID)
        
        documentPath.setData([
            "title": category.title,
            "colorNumber": category.colorNumber,
            "description": category.description,
            "timeStamp": category.timeStamp,
            "categoryUID": category.categoryUID
        ])
        
        completion()
    }
    
    func getFavoritedCategories(categories: [Category], place: FetchedPlace, completion: @escaping (Result<[Category], Error>) -> Void) {
        
        guard let uid else {
            completion(.failure(FavoriteError.noCurrentUser))
            return
        }
        
        var tempCategories: [Category] = []
        
        let group = DispatchGroup()
        
        for category in categories {
            group.enter()
            let query = COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").whereField("placeID", isEqualTo: place.placeID)
            query.getDocuments { snapshot, error in
                defer { group.leave() }
                
                if let error {
                    print(error)
                    return
                }
                guard snapshot?.documents.count != 0 else { return }
                
                tempCategories.append(category)
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(tempCategories))
        }
    }
    
    func fetchFavorite(category: Category, completion: @escaping (Result<[FetchedPlace], Error>) -> Void) {
        guard let uid else {
            completion(.failure(FavoriteError.noCurrentUser))
            return
        }
        COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").getDocuments { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.failure(FavoriteError.noDocuemnt))
                return
            }
            
            let fetchedPlaces = documents.map({ FetchedPlace(dictionary: $0.data())})
            completion(.success(fetchedPlaces))
        }
        
    }
    
    func addFavorite(category: Category, place: FetchedPlace, completion: @escaping () -> Void) {
        isEdited = true
        guard let uid else {
            print("UID doesn't exist")
            return
        }
        
        COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").document(place.placeID).setData([
            
            "title": place.name,
            "address": place.address,
            "lat": place.lat,
            "lon": place.lon,
            "placeID": place.placeID,
            "rating": place.rating,
            "type": place.type
        ])
        completion()
        
    }
    
    func deleteFavorite(category: Category, place: FetchedPlace, completion: @escaping () -> Void) {
        isEdited = true
        guard let uid else { return }
        
        COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").document(place.placeID).delete { _ in
            completion()
        }
    }
}
