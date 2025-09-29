//
//  ColorTransformer.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 27.09.2025.
//

import Foundation
import UIKit

@objc(ColorTransformer)
final class ColorTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }

    static func register() {
        let name = NSValueTransformerName(rawValue: String(describing: ColorTransformer.self))
        let transformer = ColorTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
