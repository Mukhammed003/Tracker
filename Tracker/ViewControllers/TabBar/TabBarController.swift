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
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setUpTabs() {
        let trackerViewController = TrackersViewController()
        let firstNav = UINavigationController(rootViewController: trackerViewController)
        
        let titleOfFirstTabBarItem = NSLocalizedString("title_of_firstTabBarItem", comment: "")
        
        firstNav.tabBarItem = UITabBarItem(
            title: titleOfFirstTabBarItem,
            image: UIImage(resource: .tabTrackersActive),
            selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        let secondNav = UINavigationController(rootViewController: statisticsViewController)
        
        let titleOfSecondTabBarItem = NSLocalizedString("title_of_secondTabBarItem", comment: "")
        
        secondNav.tabBarItem = UITabBarItem(
            title: titleOfSecondTabBarItem,
            image: .tabStatisticsActive,
            selectedImage: nil)
        
        viewControllers = [firstNav, secondNav]
    }
}
