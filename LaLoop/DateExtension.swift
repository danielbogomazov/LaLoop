//
//  DateExtension.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-04-20.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
