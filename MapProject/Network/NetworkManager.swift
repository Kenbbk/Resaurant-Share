//
//  NetworkManager.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/06/12.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let decoder = JSONDecoder()

    
    func getSearchResult(query: String, completion: @escaping ([Place]?) -> Void) {
        let display = 5
        let start = 1
        let sort = "random"
        let urlString = "https://openapi.naver.com/v1/search/local.json?query=\(query)&display=\(display)&start=\(start)&sort=\(sort)"
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Not Valid encodedURL")
            completion(nil)
            return
        }
        let url = URL(string: encodedURL)!

        var request = URLRequest(url: url)

        let header = [
            "X-Naver-Client-Id": "2tNhIG5HIfQ1TlomSj1I",
            "X-Naver-Client-Secret" : "uabqDuJTwM"
        ]
        request.allHTTPHeaderFields = header

        let session = URLSession.shared.dataTask(with: request) { data, _ , error in
            if error != nil {
                print(error)
                completion(nil)
                return
            }
            guard let data else {
                completion(nil)
                return
            }

            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(NaverSearchResult.self, from: data)
                let places = decodedData.items
                completion(places)
            } catch {
                print(error)
                completion(nil)
            }

        }
        session.resume()


    }

    
    func getLatLon(with address: String, completion: @escaping (Address?) -> Void) {
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=\(address)"
        
        let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encodedURL )
        
        guard let url else {
            print("There is an error creating URL")
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        
        let header = [
            "X-NCP-APIGW-API-KEY-ID": "9wocr8t7k6",
            "X-NCP-APIGW-API-KEY" : "JVAHQQClbXNB4MWM45S1noCEkOYH8KNFSadvSajV"
        ]
        
        request.allHTTPHeaderFields = header
        
        let session = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                print("There is an error in the beginning \(error)")
                completion(nil)
                return
            }
            
            guard let data else { completion(nil); return }
            do {
                let decodedData = try self.decoder.decode(NaverLocation.self, from: data)
                let addresses = decodedData.addresses
                let address = addresses.first
                completion(address)
            } catch {
                print(error)
                completion(nil)
            }
            
        }
        session.resume()
    }
    
}




//        let session = URLSession.shared.dataTask(with: request) { data, _, error in
//            if let error {
//                print("There is an error in the beginning \(error)")
//                return
//            }
//            guard let data else { return }
//            do {
//                let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
//                print(dictionary!)
//            } catch {
//                print("There is an catch error \(error)")
//            }
//
//
//        }.resume()



//    let urlString = "https://openapi.naver.com/v1/search/local.json?query=\(string)&display=5&start=1&sort=random"
//    let result = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//    print(result)
//    let url = URL(string: result )
//
//    guard let url else {
//        print("There is an error creating URL")
//        completion(nil)
//        return
//    }
//
//    var request = URLRequest(url: url)
//
//    let header = [
//        "X-Naver-Client-Id": "2tNhIG5HIfQ1TlomSj1I",
//        "X-Naver-Client-Secret" : "uabqDuJTwM"
//    ]
//
//    request.allHTTPHeaderFields = header
//
//    let session = URLSession.shared.dataTask(with: request) { data, response, error in
//        if let error {
//            print(error)
//            completion(nil)
//            return
//        }
//        guard let data else {
//            completion(nil)
//            return
//
//        }
//       let decoder = JSONDecoder()
//        do {
//            let decodedData = try decoder.decode(SearchData.self, from: data)
//            let items = decodedData.items
//            completion(items)
////                print(decodedData.display)
////                print(decodedData.total)
////                print(decodedData.start)
////                for item in decodedData.items {
////                    print(item.mapx, item.mapy)
////                }
//        } catch {
//            print(error)
//            completion(nil)
//        }
//
//
//    }.resume()


