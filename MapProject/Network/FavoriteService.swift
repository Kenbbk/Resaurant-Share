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

protocol FavoriteServiceDelegate: AnyObject {
    func updateBeenMade()
}

enum FBError: Error {
    case noCategory
    case noUserUID
    
}

class FavoriteSerivce {
    
    
    weak var delegate: FavoriteServiceDelegate?
    
    enum FavoriteError: Error {
        case noCurrentUser
        case noDocuemnt
    }
    
    static let shared = FavoriteSerivce()
    
    private init() {}
    
    let uid = Auth.auth().currentUser?.uid
    
    
//    func fetchFavoritePlaces(from category: [Category]) async throws -> [Category] {
//        
//        guard let uid else { throw FBError.noUserUID }
//        
//        
//    }
    
    
    func fetchFavoritePlaces(from category: Category) async throws -> [FetchedPlace] {
        
        guard let uid else { throw FBError.noUserUID }
        
        let fetchedPlaces = try await COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").getDocuments().documents
            .map { FetchedPlace(dictionary: $0.data()) }
        
        return fetchedPlaces
        
    }
    
    func addFavorite(the place: FetchedPlace, to categories: [Category] ) async throws {
//        delegate?.updateBeenMade()
        
        guard let uid else { throw FBError.noUserUID }
        
        await withThrowingTaskGroup(of: type(of: ())) { group in
            for category in categories {
                group.addTask {
                    try await self.addFavorite(this: place, to: category)
                }
            }
        }
        
    }
    
    
    
    func addFavorite(this place: FetchedPlace, to category: Category) async throws {
        delegate?.updateBeenMade()
        
        guard let uid else { throw FBError.noUserUID }
        
        try await COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").document(place.placeID).setData([
            
            "title": place.name,
            "address": place.address,
            "lat": place.lat,
            "lon": place.lon,
            "placeID": place.placeID,
            "rating": place.rating,
            "type": place.type
        ])
        
        
    }
    
    func deleteFavorite(place: FetchedPlace, in category: Category) async throws {
        delegate?.updateBeenMade()
        
        guard let uid else { throw FBError.noUserUID }
        
        try await COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").document(place.placeID).delete()
        
    }
    
    func deleteFavorite(categories: [Category], place: FetchedPlace) async throws {
     
        guard let uid else { throw FBError.noUserUID }
        
        await withThrowingTaskGroup(of: type(of: ())) { group in
            for category in categories {
                group.addTask {
                    try await self.deleteFavorite(place: place, in: category)
                }

            }
        }
        
    }
    
//    func deleteFavorite(category: Category, places: [FetchedPlace]) async throws {
//        delegate?.updateBeenMade()
//
//        guard let uid else { throw FBError.noUserUID }
//
//
//
//
//        _ = await withThrowingTaskGroup(of: type(of: ())) { group in
//            for place in places {
//                group.addTask {
//                    try await self.deleteFavorite(category: category, place: place)
//                }
//
//            }
//        }
//
//    }
    
    
    
}
    
    
    
    
    
    
    
    
    
//    func getFavoritedCategories(categories: [Category], place: FetchedPlace, completion: @escaping (Result<[Category], Error>) -> Void) {
//
//        guard let uid else {
//            completion(.failure(FavoriteError.noCurrentUser))
//            return
//        }
//
//        var tempCategories: [Category] = []
//
//        let group = DispatchGroup()
//
//        for category in categories {
//            group.enter()
//            let query = COLLECTION_USERS.document(uid).collection("categories").document(category.categoryUID).collection("places").whereField("placeID", isEqualTo: place.placeID)
//            query.getDocuments { snapshot, error in
//                defer { group.leave() }
//
//                if let error {
//                    print(error)
//                    return
//                }
//                guard snapshot?.documents.count != 0 else { return }
//
//                tempCategories.append(category)
//            }
//        }
//
//        group.notify(queue: .main) {
//            completion(.success(tempCategories))
//        }
//    }
    
    
    
    

