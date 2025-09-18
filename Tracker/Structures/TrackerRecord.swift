//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 26.08.2025.
//

import UIKit

struct TrackerRecord: Hashable {
    let id: UInt
    let date: Date
    
    init(id: UInt, date: Date) {
            self.id = id
            self.date = Calendar.current.startOfDay(for: date)
        }
}
