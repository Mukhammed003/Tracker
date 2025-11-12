//
//  Untitled.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 09.11.2025.
//

import AppMetricaCore

final class AnalyticsService {
    
    static func activate() {
        if let configuration = AppMetricaConfiguration(apiKey: "44ead0c0-d337-4a20-ae21-add5919408fd") {
            AppMetrica.activate(with: configuration)
        }
    }
    
    static func addEvent(eventName withName: String, params: [AnyHashable: Any]) {
        
        AppMetrica.reportEvent(
            name: withName,
            parameters: params,
            onFailure: { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            })
    }
    
}
