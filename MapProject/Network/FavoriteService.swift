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
    
    static let uid = Auth.auth().currentUser?.uid
    
    static func fetchCategory(completion: @escaping ([Category]) -> Void ) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        
        COLLECTION_USERS.document(uid).collection("categories").getDocuments { snapShot, error in
            
            
            
            guard let documents = snapShot?.documents else { return }
            
            let categories = documents.map( { Category(dictionary: $0.data())})
            
            completion(categories)
        }
    }
    
    static func addCategory(with category: Category, completion: @escaping (Category) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        
        let documentPath = COLLECTION_USERS.document(uid).collection("categories").document()
        
        documentPath.setData([
            "title": category.title,
            "colorNumber": category.colorNumber,
            "description": category.description,
            "timeStamp": category.timeStamp,
            "categoryUID": documentPath.documentID
        ])
        
        var newCateogry = category
        newCateogry.categoryUID = documentPath.documentID
        completion(newCateogry)
    }
    
//    static func deleteCategory(with category: Category, completion: @escaping () -> Void) {
//
//        guard let user = Auth.auth().currentUser else { return }
//        guard let categoryUID = category.categoryUID else { return }
//        let uid = user.uid
//        COLLECTION_USERS.document(uid).collection("categories").document(categoryUID).delete { _ in
//            completion()
//        }
//    }
    
    //    static func fetchCategory() {
    //        guard let user = Auth.auth().currentUser else { return }
    //        let uid = user.uid
    //
    //        COLLECTION_USERS.document(uid).collection("category").getd
    //    }
    
    static func addFavorite(category: Category, place: FetchedPlace, completion: @escaping () -> Void) {
        guard let uid else {
            print("UID doesn't exist")
            return }
        
        guard let categoryUID = category.categoryUID else {
            print("CategoryUID doesn't exist")
            return }
        
        COLLECTION_USERS.document(uid).collection("categories").document(categoryUID).collection("places").document(place.title).setData([
            "title": place.title,
            "address": place.address,
            "lat": place.lat,
            "lon": place.lon
        ])
            completion()
       
    }
    
    static func deleteFavorite(category: Category, place: FetchedPlace, completion: @escaping () -> Void) {
        guard let uid else { return }
        guard let categoryUID = category.categoryUID else { return }
        COLLECTION_USERS.document(uid).collection("categories").document(categoryUID).collection("places").document(place.title).delete { _ in
            completion()
        }
          
            
       
    }
    
    
    
    //    static func uploadFavorite(title: String, address: String, lat: Double, lon: Double) {
    //        guard let user = Auth.auth().currentUser else { return }
    //        let uid = user.uid
    //
    //        COLLECTION_USERS.document(uid).collection("category").document(title).setData([
    //            "title": title,
    //            "address": address,
    //            "lat": lat,
    //            "lon": lon
    //        ])
    //    }
    //}
}
