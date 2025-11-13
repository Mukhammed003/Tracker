//
//  FirstOnboardingViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 22.10.2025.
//

import UIKit

final class FirstOnboardingViewController: UIViewController {
    
    private lazy var onboardingLabel: UILabel = makeOnboardingLabel()
    private lazy var backgroundImage: UIImageView = makeBackgroundImage()
    private lazy var onboardingButton: UIButton = makeOnboardingButton()
    
    @objc private func clickToOnboardingButton() {
        let tabBarController = TabBarController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.setRoot(tabBarController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        [backgroundImage, onboardingLabel, onboardingButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            onboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60),
            
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onboardingLabel.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -160)
        ])
    }
    
    private func makeOnboardingLabel() -> UILabel {
        let onboardingLabel = UILabel()
        
        onboardingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let onboardingText = NSLocalizedString("onboarding.firstPage.text", comment: "")
        
        let attributedString = NSAttributedString(
            string: onboardingText,
            attributes: [
                .kern: 0,
                .foregroundColor: UIColor.ypBlack,
                .font: UIFont.systemFont(ofSize: 32, weight: .bold)
            ]
        )
        onboardingLabel.attributedText = attributedString
        
        onboardingLabel.textAlignment = .center
        onboardingLabel.numberOfLines = 2
        onboardingLabel.lineBreakMode = .byWordWrapping
        
        return onboardingLabel
    }
    
    private func makeBackgroundImage() -> UIImageView {
        let exampleImage = UIImage(resource: .firstOnboardingBackground)
        let backgroundImageView = UIImageView(image: exampleImage)
        backgroundImageView.clipsToBounds = true
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return backgroundImageView
    }
    
    private func makeOnboardingButton() -> UIButton {
        let onboardingButton = UIButton(type: .custom)
        
        let textOfOnboardingButton = NSLocalizedString("onboarding.button.text", comment: "")
        
        onboardingButton.setTitle(textOfOnboardingButton, for: .normal)
        onboardingButton.setTitleColor(.systemBackground, for: .normal)
        onboardingButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        onboardingButton.contentHorizontalAlignment = .center
        onboardingButton.backgroundColor = .ypBlack
        onboardingButton.layer.cornerRadius = 16
        onboardingButton.addTarget(self, action: #selector(clickToOnboardingButton), for: .touchUpInside)
        onboardingButton.translatesAutoresizingMaskIntoConstraints = false
        
        return onboardingButton
    }
}
