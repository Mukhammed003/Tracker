//
//  Untitled.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 09.11.2025.
//

import AppMetricaCore

final class AnalyticsService {
    
    func addEvent(eventName withName: String, params: [AnyHashable: Any]) {
        
        AppMetrica.reportEvent(
            name: withName,
            parameters: params,
            onFailure: { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            })
    }
    
}
