//
//  Places.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/12.
//

import Foundation

struct NaverSearchResult: Codable {
    let total: Int
    let items: [Place]
}

struct Place: Codable {
    let address: String
    
    let roadAddress: String
    let title: String
}

struct FetchedPlace {
    let address: String
    let title: String
    let lat: Double
    let lon: Double
    
    init(dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? ""
        self.address = dictionary["address"] as? String ?? ""
        self.lat = dictionary["lat"] as? Double ?? 0
        self.lon = dictionary["lon"] as? Double ?? 0
    }
}

