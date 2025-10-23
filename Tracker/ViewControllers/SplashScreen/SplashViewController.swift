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
        
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")

        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            print("Первый запуск приложения")
            showOnboardingViewController()
        } else {
            print("Повторный запуск приложения")
            showTabBarController()
        }
    }
    
    private func showTabBarController() {
        let tabBarController = TabBarController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.setRoot(tabBarController, animated: true)
        }
    }
    
    private func showOnboardingViewController() {
        let onboardingViewController = OnboardingViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.setRoot(onboardingViewController, animated: true)
        }
    }
    
}
