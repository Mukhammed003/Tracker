//
//  SecondOnboardingViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 22.10.2025.
//

import UIKit

final class SecondOnboardingViewController: UIViewController {
    
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
        let exampleLabel = UILabel()
        
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedString = NSAttributedString(
            string: "Даже если это не литры воды и йога",
            attributes: [
                .kern: 0,
                .foregroundColor: UIColor.ypBlack,
                .font: UIFont.systemFont(ofSize: 32, weight: .bold)
            ]
        )
        exampleLabel.attributedText = attributedString
        
        exampleLabel.textAlignment = .center
        exampleLabel.numberOfLines = 2
        exampleLabel.lineBreakMode = .byWordWrapping
        
        return exampleLabel
    }
    
    private func makeBackgroundImage() -> UIImageView {
        let exampleImage = UIImage(resource: .secondOnboardingBackground)
        let exampleImageView = UIImageView(image: exampleImage)
        exampleImageView.clipsToBounds = true
        
        exampleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return exampleImageView
    }
    
    private func makeOnboardingButton() -> UIButton {
        let readyButton = UIButton(type: .custom)
        readyButton.setTitle("Вот это технологии!", for: .normal)
        readyButton.setTitleColor(.systemBackground, for: .normal)
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.contentHorizontalAlignment = .center
        readyButton.backgroundColor = .ypBlack
        readyButton.layer.cornerRadius = 16
        readyButton.addTarget(self, action: #selector(clickToOnboardingButton), for: .touchUpInside)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        
        return readyButton
    }
}
