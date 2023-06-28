//
//  NaverLocation.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/12.
//

import Foundation

struct NaverLocation: Codable {
    let errorMessage: String
    let addresses: [Address]
}

struct Address: Codable {
    let englishAddress: String
    let x: String
    let y: String
    let distance: Double
    
}

