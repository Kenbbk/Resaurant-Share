//
//  Date+Ext.swift
//  MapProject
//
//  Created by t2023-m0073 on 2023/08/03.
//

import Foundation

extension Date {
    
    func pastDate() -> Date {
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .year, value: -1, to: self)
        return newDate!
    }
    
}
