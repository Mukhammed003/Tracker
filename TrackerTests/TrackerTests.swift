//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Muhammed Nurmukhanov on 09.11.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewControllerWhiteMode() {
        let tabBarController = TabBarController()
        tabBarController.loadViewIfNeeded()
        
        tabBarController.view.frame = UIScreen.main.bounds
        tabBarController.view.layoutIfNeeded()
        
        tabBarController.selectedIndex = 0
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        
        let record = false
        assertSnapshot(matching: tabBarController, as: .image(on: .iPhone13, traits: lightTraits), record: record)
    }

    func testViewControllerDarkMode() {
        let tabBarController = TabBarController()
        tabBarController.loadViewIfNeeded()
        
        tabBarController.view.frame = UIScreen.main.bounds
        tabBarController.view.layoutIfNeeded()
        
        tabBarController.selectedIndex = 0
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        
        let record = false
        assertSnapshot(matching: tabBarController, as: .image(on: .iPhone13, traits: darkTraits), record: record)
    }
}
