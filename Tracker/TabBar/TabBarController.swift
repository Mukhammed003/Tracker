//
//  TabBarController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 17.08.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }
    
    private func setUpTabs() {
        let trackerViewController = TrackersViewController()
        let firstNav = UINavigationController(rootViewController: trackerViewController)
        firstNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabTrackersActive),
            selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        let secondNav = UINavigationController(rootViewController: statisticsViewController)
        secondNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: .tabStatisticsActive,
            selectedImage: nil)
        
        viewControllers = [firstNav, secondNav]
    }
}
