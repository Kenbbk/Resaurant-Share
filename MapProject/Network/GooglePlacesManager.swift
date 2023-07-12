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
    
    private let cache = NSCache<NSString, NSArray>()
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
        
        let url = URL(string: urlString)
        
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                print(error)
                return
            }
            
            guard let data else { return }
            let stringData = String(data: data, encoding: .utf8)
            //            print(stringData)
            
        }
        task.resume()
        
    }
    
    func resolveLocation(with placeID: String, completion: @escaping (Result<FetchedPlace, Error>) -> Void) {
        
        
        client.fetchPlace(fromPlaceID: placeID, placeFields: [.name, .formattedAddress, .coordinate, .placeID, .rating, .photos, .types], sessionToken: nil) { resolvedPlace, error in
            guard let resolvedPlace else {
                completion(.failure(PlacesError.failedToFind))
                return
            }
            
            
            let place = FetchedPlace(name: resolvedPlace.name!, address: resolvedPlace.formattedAddress! , placeID: resolvedPlace.placeID!, rating: resolvedPlace.rating, lat: resolvedPlace.coordinate.latitude, lon: resolvedPlace.coordinate.longitude, type: resolvedPlace.types?.first ?? "", image: resolvedPlace.photos ?? [])
            completion(.success(place))
            
        }
        
        
    }
    
    func decodePhotoData(place: FetchedPlace, completion: @escaping ([UIImage]?) -> Void) {
        
        if let images = cache.object(forKey: NSString(string: place.placeID)) {
            let objArray = NSMutableArray(array: images)
            if let swiftArray = objArray as NSArray as? [UIImage] {
                
                completion(swiftArray)
            }
            return
        }
        
        
        var tempPhotoArray: [UIImage] = []
        let photoData = place.image
        
        let group = DispatchGroup()
        for data in photoData {
            group.enter()
            client.loadPlacePhoto(data) { image, error in
                defer {
                    group.leave()
                }
                if let error {
                    print(error)
                    return
                }
                
                guard let image else { return }
                
                tempPhotoArray.append(image)
                
            }
        }
        
        group.notify(queue: .main) {
            completion(tempPhotoArray)
            if place.name == "RRACE" {
                print("RRACE is ready")
            }
            if place.name == "RR쇼륨" {
                print("RR쇼륨 photo is already up")
            }
            self.cache.setObject(NSArray(array: tempPhotoArray), forKey: NSString(string: place.placeID))
        }
    }
    
//    func decodePhotoData(photoData: [GMSPlacePhotoMetadata]) {
//        var photoArray: [UIImage] = []
//        let firstThreeData = photoData.prefix(3)
//
//        let group = DispatchGroup()
//
//        for data in firstThreeData {
//            group.enter()
//            client.loadPlacePhoto(data) { image, error in
//                defer { group.leave() }
//                if let error {
//                    print(error)
//                    return
//                }
//                guard let image else { return }
//                photoArray.append(image)
//            }
//        }
//        group.notify(queue: .main) {
//
//        }
//
//    }
}


