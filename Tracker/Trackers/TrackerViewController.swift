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
    private lazy var headerTrackersLabel: UILabel = makeHeaderTrackersLabel()
    private lazy var searchField: UITextField = makeSearchField()
    private lazy var notFoundImage: UIImageView = makeNotFoundImage()
    private lazy var notFoundLabel: UILabel = makeNotFoundLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        setupConstraints()
    }
    
    @objc private func clickToAddTrackerButton() {
        
    }
    
    @objc private func clickToDatePickerButton() {
        
    }
    
    private func addSubviews() {
         [headerTrackersLabel, searchField,  notFoundImage, notFoundLabel, addTrackerButton, datePickerButton].forEach {
                view.addSubview($0)
            }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            
            datePickerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            datePickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            headerTrackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerTrackersLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            headerTrackersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -105),
            
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.topAnchor.constraint(equalTo: headerTrackersLabel.bottomAnchor, constant: 7),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
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
        let addTrackerButton = createUIButton(imageForButton: "add_tracker_icon", forSelector: #selector(clickToAddTrackerButton), colorOfIcon: .black)
        
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
    
    private func makeHeaderTrackersLabel() -> UILabel {
        let headerTrackersLabel = createUILabel(
            textOfLabel: "Трекеры",
            letterSpacing: 0,
            colorOfLabel: .ypBlack,
            fontSizeOfLabel: 34,
            weightOfLabel: .bold)
        
        return headerTrackersLabel
    }
    
    private func makeSearchField() -> UITextField {
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
    
    private func createSearchTextField(placeholderText: String) -> UITextField {
        let someSearchField = UITextField()
        someSearchField.layer.cornerRadius = 10
        someSearchField.backgroundColor = .ypGray
        someSearchField.translatesAutoresizingMaskIntoConstraints = false
        someSearchField.textColor = .ypTextOfSearchField
        someSearchField.tintColor = UIColor.gray.withAlphaComponent(0.5)
//        someSearchField.becomeFirstResponder()
                
        someSearchField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [
                .foregroundColor: UIColor.ypTextOfSearchField.withAlphaComponent(0.5)
            ]
        )
        
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .ypTextOfSearchField
        searchIcon.contentMode = .scaleAspectFit
                
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        searchIcon.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
        paddingView.addSubview(searchIcon)
                
        someSearchField.leftView = paddingView
        someSearchField.leftViewMode = .always
        
        return someSearchField
    }
}
