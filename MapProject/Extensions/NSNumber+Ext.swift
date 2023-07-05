//
//  NSNumber+Ext.swift
//  MapProject
//
//  Created by Woojun Lee on 2023/07/03.
//

import Foundation

extension NSNumber {
    func getDistanceString() -> String {
        let FloatNumber = Float(self)
        if FloatNumber > 10_000 {
            let rounded = (FloatNumber / 1000).rounded()
           return "\(Int(rounded))Km"
        } else if FloatNumber > 1_000 {
            let rounded = (FloatNumber / 100).rounded()
             return "\(rounded / 10)Km"
        } else {
            return "\(Int(FloatNumber))m"
        }
        
            
    }
}
