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
}
