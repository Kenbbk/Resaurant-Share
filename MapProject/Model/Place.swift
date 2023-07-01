//
//  Place.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/01.
//

import Foundation

struct Place {
    let name: String
    let identifier: String
    let distance: NSNumber
    
}

struct FetchedPlace {
    let name: String
    let address: String
    let placeID: String
    let rating: Float
    let lat: Double
    let lon: Double
    
    init(name: String, address: String, placeID: String, rating: Float, lat: Double, lon: Double) {
        self.name = name
        self.address = address
        self.placeID = placeID
        self.rating = rating
        self.lat = lat
        self.lon = lon
    }
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["title"] as? String ?? ""
        self.address = dictionary["address"] as? String ?? ""
        self.placeID = dictionary["placeID"] as? String ?? ""
        self.rating = dictionary["rating"] as? Float ?? 0
        self.lat = dictionary["lat"] as? Double ?? 0
        self.lon = dictionary["lon"] as? Double ?? 0
    }
}
