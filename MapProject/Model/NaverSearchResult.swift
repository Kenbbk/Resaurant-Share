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
    let category: String
    let roadAddress: String
    let title: String
    let link: String


}
//struct SearchData: Codable {
//    let display: Int
//    let total: Int
//    let start: Int
//    let items: [Item]
//}
//
//struct Item: Codable {
//    let title: String
//    let address: String
//    let mapx: String
//    let mapy: String
////    let mapy: Double
//}
