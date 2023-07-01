//
//  FavoriteService.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

let COLLECTION_USERS = Firestore.firestore().collection("users")

struct FavoriteSerivce {
    
    enum FavoriteError: Error {
        case noCurrentUser
        case noDocuemnt
    }
    
    static let shared = FavoriteSerivce()
    
    private init() {}
    
    let uid = Auth.auth().currentUser?.uid
    
    func fetchCategory(completion: @escaping ([Category]) -> Void ) {
        guard let uid else { return }
        
        COLLECTION_USERS.document(uid).collection("categories").getDocuments { snapShot, error in
            
            guard let documents = snapShot?.documents else { return }
            
            let categories = documents.map( { Category(dictionary: $0.data())})
            
            completion(categories)
        }
    }
    
    func addCategory(with category: Category, completion: @escaping () -> Void) {
        
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
            "rating": place.rating
        ])
        completion()
        
    }
    
    func deleteFavorite(category: Category, place: FetchedPlace, completion: @escaping () -> Void) {
        guard let uid else { return }
        
        COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").document(place.placeID).delete { _ in
            completion()
        }
    }
}
