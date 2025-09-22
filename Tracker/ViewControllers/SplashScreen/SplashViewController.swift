//
//  SplashViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 17.08.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlue
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showTabBarController()
    }
    
    
    private func showTabBarController() {
        let tabBarController = TabBarController()
        
        if let window = view.window ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
            window.setRoot(tabBarController, animated: true)
        }
    }
    
}
