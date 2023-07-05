//
//  Place.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/01.
//

import Foundation
import UIKit
import GooglePlaces

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
    let image: GMSPlacePhotoMetadata?
    let type: String
    
    init(name: String, address: String, placeID: String, rating: Float, lat: Double, lon: Double, type: String ,image: GMSPlacePhotoMetadata? = nil) {
        self.name    = name
        self.address = address
        self.placeID = placeID
        self.rating  = rating
        self.lat     = lat
        self.lon     = lon
        self.type    = type
        self.image   = image
    }
    
    init(dictionary: [String: Any]) {
        self.name       = dictionary["title"] as? String ?? ""
        self.address    = dictionary["address"] as? String ?? ""
        self.placeID    = dictionary["placeID"] as? String ?? ""
        self.rating     = dictionary["rating"] as? Float ?? 0
        self.lat        = dictionary["lat"] as? Double ?? 0
        self.lon        = dictionary["lon"] as? Double ?? 0
        self.type       = dictionary["type"] as? String ?? ""
        self.image      = nil
    }
}
