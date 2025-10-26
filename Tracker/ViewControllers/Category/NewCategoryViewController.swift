//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 25.10.2025.
//

import UIKit

final class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    var onNewCategoryCreated: ((String) -> Void)?
    
    private var isTextFieldFilled = false
    
    private lazy var categoryNameTextField: UITextField = makeCategoryNameTextField()
    private lazy var readyButton: UIButton = makeReadyButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Новая категория"
        
        addSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryNameTextField.becomeFirstResponder()
    }
    
    @objc private func buttonReadyClicked() {
        guard let text = categoryNameTextField.text,
              !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        onNewCategoryCreated?(text)
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        isTextFieldFilled = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        updateReadyButtonState()
    }
    
    private func addSubViews() {
        [categoryNameTextField, readyButton].forEach {
            view.addSubview($0)
        }
        
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func makeReadyButton() -> UIButton {
        let addCategoryButton = UIButton(type: .custom)
        addCategoryButton.setTitle("Готово", for: .normal)
        addCategoryButton.setTitleColor(.systemBackground, for: .normal)
        addCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.contentHorizontalAlignment = .center
        addCategoryButton.backgroundColor = .ypGray
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.addTarget(self, action: #selector(buttonReadyClicked), for: .touchUpInside)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        return addCategoryButton
    }
    
    private func makeCategoryNameTextField() -> UITextField {
        let trackerNameTextField = UITextField()
        trackerNameTextField.placeholder = "Введите название категории"
        trackerNameTextField.backgroundColor = .ypBackground
        trackerNameTextField.layer.cornerRadius = 16
        trackerNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        trackerNameTextField.delegate = self
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return trackerNameTextField
    }
    
    private func updateReadyButtonState() {
        let shouldBeActive = isTextFieldFilled
        
        readyButton.isEnabled = shouldBeActive
        UIView.animate(withDuration: 0.3) {
            self.readyButton.backgroundColor = shouldBeActive ? .ypBlack : .ypGray
        }
    }
    
}

