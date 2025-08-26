//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 17.08.2025.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    private lazy var addTrackerButton: UIButton = makeAddTrackerButton()
    private lazy var datePickerButton: UIButton = makeDatePickerButton()
    private lazy var searchField: UISearchController = makeSearchField()
    private lazy var notFoundImage: UIImageView = makeNotFoundImage()
    private lazy var notFoundLabel: UILabel = makeNotFoundLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavBar()
        addSubviews()
        setupConstraints()
    }
    
    @objc private func clickToAddTrackerButton() {
        
    }
    
    @objc private func clickToDatePickerButton() {
        
    }
    
    private func setupNavBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)

        navigationItem.searchController = searchField
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func addSubviews() {
         [notFoundImage, notFoundLabel].forEach {
                view.addSubview($0)
            }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            notFoundImage.heightAnchor.constraint(equalToConstant: 80),
            notFoundImage.widthAnchor.constraint(equalToConstant: 80),
            notFoundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            notFoundLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            notFoundLabel.topAnchor.constraint(equalTo: notFoundImage.bottomAnchor, constant: 8),
            notFoundLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func makeAddTrackerButton() -> UIButton {
        let addTrackerButton = createUIButton(imageForButton: "plus", forSelector: #selector(clickToAddTrackerButton), colorOfIcon: .black)
        
        return addTrackerButton
    }
    
    private func makeDatePickerButton() -> UIButton {
        let datePickerButton = createTextButton(
            title: "14.12.22",
            forSelector: #selector(clickToDatePickerButton),
            titleColor: .ypBlack,
            backgroundColor: .ypGray,
            cornerRadius: 8)
        
        return datePickerButton
    }
    
    private func makeSearchField() -> UISearchController {
        let searchField = createSearchTextField(placeholderText: "Поиск")
        
        return searchField
    }
    
    private func makeNotFoundImage() -> UIImageView {
        let notFoundImage = createUIImageView(
            nameOfImage: "not_found_image",
            radiusIfNeeded: 0)
        
        return notFoundImage
    }
    
    private func makeNotFoundLabel() -> UILabel {
        let notFoundLabel = createUILabel(
            textOfLabel: "Что будем отслеживать?",
            letterSpacing: 0,
            colorOfLabel: .ypBlack,
            fontSizeOfLabel: 12,
            weightOfLabel: .medium)
        
        notFoundLabel.textAlignment = .center
        
        return notFoundLabel
    }
    
    private func createUIImageView(nameOfImage imageName: String, radiusIfNeeded cornerRadius: CGFloat) -> UIImageView {
        let exampleImage = UIImage(named: imageName)
        let exampleImageView = UIImageView(image: exampleImage)
        exampleImageView.clipsToBounds = true
        
        if cornerRadius != 0 {
            exampleImageView.layer.cornerRadius = cornerRadius
        }
        
        exampleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return exampleImageView
    }
    
    private func createUIButton(imageForButton name: String, forSelector selector: Selector, colorOfIcon tintColor: UIColor) -> UIButton {
        let exampleButton = UIButton(type: .system)
            
        if let buttonImage = UIImage(systemName: name) {
                exampleButton.setImage(buttonImage, for: .normal)
        } else if let buttonImage = UIImage(named: name) {
                exampleButton.setImage(buttonImage, for: .normal)
        }
        
        exampleButton.tintColor = tintColor
        
        exampleButton.translatesAutoresizingMaskIntoConstraints = false
        
        exampleButton.addTarget(self, action: selector, for: .touchUpInside)
        
        return exampleButton
    }
    
    private func createTextButton(
        title: String,
        forSelector selector: Selector,
        titleColor: UIColor,
        backgroundColor: UIColor,
        cornerRadius: CGFloat
    ) -> UIButton {
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        
        button.titleLabel?.font = UIFont(name: "YP-Regular", size: 17)
        
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 77),
                button.heightAnchor.constraint(equalToConstant: 34)
            ])
        
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        return button
    }
    
    private func createUILabel(textOfLabel exampleText: String, letterSpacing kern: CGFloat, colorOfLabel foregroundColor: UIColor, fontSizeOfLabel fontSize: CGFloat, weightOfLabel weight: UIFont.Weight) -> UILabel {
        let exampleLabel = UILabel()
        
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedString = NSAttributedString(
            string: exampleText,
            attributes: [
                .kern: kern,
                .foregroundColor: foregroundColor,
                .font: UIFont.systemFont(ofSize: fontSize, weight: weight)
            ]
        )
        exampleLabel.attributedText = attributedString
        
        return exampleLabel
    }
    
    private func createSearchTextField(placeholderText: String) -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = placeholderText
        
        return searchController
    }
}
