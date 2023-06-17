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
    
    
    
    static func fetchFavorite(category: String, completion: @escaping ([FetchedPlace]) -> Void ) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        
        COLLECTION_USERS.document(uid).collection("category").getDocuments { snapShot, error in
            
            var places: [FetchedPlace] = []
            
            let documents = snapShot?.documents
            documents?.forEach({
                let data = $0.data()
                let place = FetchedPlace(dictionary: data)
                
                places.append(place)
            })
            
            completion(places)
        }
    }
    
    static func uploadFavorite(title: String, address: String, lat: Double, lon: Double) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        COLLECTION_USERS.document(uid).collection("category").document(title).setData([
            "title": title,
            "address": address,
            "lat": lat,
            "lon": lon
        ])
    }
}
