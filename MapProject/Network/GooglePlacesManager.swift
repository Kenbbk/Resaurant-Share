//
//  GoogleService.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/30.
//

import Foundation
import GooglePlaces



class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    
    private init() {}
    
    let apiKey = "AIzaSyCA21Ewz2n1VQ8j_NXlrLAxbcUdMrmgPQE"
    
    public func setUp() {
        
    }
    
    enum PlacesError: Error {
        case failedToFind
    }
    
    func findPlaces(query: String, completion: @escaping (Result<[Place], Error>) -> Void) {
        let filter = GMSAutocompleteFilter()
        
        filter.type = .establishment
        filter.origin = CLLocation(latitude: 35.317826, longitude: 128.988118)
        
        filter.countries = ["KR"]
        
        
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
            guard let results , error == nil else {
                completion(.failure(PlacesError.failedToFind))
                return }
           
            let places: [Place] = results.compactMap({
                
                Place(name: $0.attributedPrimaryText.string, identifier: $0.placeID, distance: $0.distanceMeters!)
            })
            completion(.success(places))
        }
        
        
    }
    
    func getNearbyrestaurant() {
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants%20in%20Busan&language=ko&key=\(apiKey)"
//        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?location=42.3675294%2C-71.186966&query=123%20main%20street&radius=10000&key=\(apiKey)"
        print(urlString)
        let url = URL(string: urlString)
        
        let request = URLRequest(url: url!)
        let session = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                print(error)
                return
            }
            
            guard let data else { return }
            let stringData = String(data: data, encoding: .utf8)
            print(stringData)
            
        }.resume()
        
    }
    
    func resolveLocation(with placeID: String, completion: @escaping (Result<FetchedPlace, Error>) -> Void) {
        
        
        client.fetchPlace(fromPlaceID: placeID, placeFields: [.name, .formattedAddress, .coordinate, .placeID, .rating], sessionToken: nil) { resolvedPlace, error in
            guard let resolvedPlace else {
                completion(.failure(PlacesError.failedToFind))
                return }
            
            let place = FetchedPlace(name: resolvedPlace.name!, address: resolvedPlace.formattedAddress! , placeID: resolvedPlace.placeID!, rating: resolvedPlace.rating, lat: resolvedPlace.coordinate.latitude, lon: resolvedPlace.coordinate.longitude)
            completion(.success(place))
//            self.client.loadPlacePhoto(photoMetadata) { photo, error in
//                if let error {
//                    print(error)
//                    return
//                } else {
//                    guard let photo else { return }
//                    completion(photo)
//                }
//            }
        }
        
        
    }
}


