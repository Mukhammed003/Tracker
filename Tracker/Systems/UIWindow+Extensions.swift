//
//  UIWindow+Extensions.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 17.08.2025.
//

import UIKit

extension UIWindow {
    func setRoot(_ viewController: UIViewController, animated: Bool = true) {
        guard animated else {
            self.rootViewController = viewController
            self.makeKeyAndVisible()
            return
        }
        
        UIView.transition(
            with: self,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.rootViewController = viewController
            })
    }
}

extension Date {
    var startOfDayUTC: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.startOfDay(for: self)
    }
}

extension DaysOfWeek {
    static func fromLocalized(_ localized: String) -> DaysOfWeek? {
        return Self.allCases.first { $0.localized == localized }
    }
}
