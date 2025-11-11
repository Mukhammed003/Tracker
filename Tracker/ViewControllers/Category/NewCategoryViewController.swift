//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 25.10.2025.
//

import UIKit

final class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    var onNewCategoryCreated: ((String) -> Void)?
    var onCategoryEdited: ((String) -> Void)?
    
    private let viewModel: NewCategoryViewModel
    private var isTextFieldFilled = false
    
    init(viewModel: NewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var categoryNameTextField: UITextField = makeCategoryNameTextField()
    private lazy var readyButton: UIButton = makeReadyButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if case .edit = viewModel.mode {
            categoryNameTextField.text = viewModel.oldCategoryName
            isTextFieldFilled = true
            updateReadyButtonState()
        }
        
        view.backgroundColor = .systemBackground
        
        let titleOfNewCategoryViewController = NSLocalizedString("title_of_newCategoryViewController", comment: "")
        
        title = titleOfNewCategoryViewController
        
        addSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryNameTextField.becomeFirstResponder()
    }
    
    @objc private func buttonReadyClicked() {
        switch viewModel.mode {
        case .create:
            guard let text = categoryNameTextField.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            let titleOfErrorAlert = NSLocalizedString("title_of_error_alert_on_newCategory_page", comment: "")
            let messageOfErrorAlert = NSLocalizedString("message_of_error_alert_on_newCategory_page", comment: "")
            
            if viewModel.isCategoryExists(text) {
                showAlert(title: titleOfErrorAlert, message: messageOfErrorAlert)
                return
            }
            
            onNewCategoryCreated?(text)
            view.endEditing(true)
        case .edit:
            guard let text = categoryNameTextField.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            let titleOfErrorAlert = NSLocalizedString("title_of_error_alert_on_newCategory_page", comment: "")
            let messageOfErrorAlert = NSLocalizedString("message_of_error_alert_on_newCategory_page", comment: "")
            
            if viewModel.isCategoryExists(text) {
                showAlert(title: titleOfErrorAlert, message: messageOfErrorAlert)
                return
            }
            
            onCategoryEdited?(text)
            view.endEditing(true)
        }
        
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
        let readyButton = UIButton(type: .custom)
        
        let textOfReadyButton = NSLocalizedString("text_of_readyButton_on_newCategory_page", comment: "")
        
        readyButton.setTitle(textOfReadyButton, for: .normal)
        readyButton.setTitleColor(.systemBackground, for: .normal)
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.contentHorizontalAlignment = .center
        readyButton.backgroundColor = .ypGray
        readyButton.layer.cornerRadius = 16
        readyButton.addTarget(self, action: #selector(buttonReadyClicked), for: .touchUpInside)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        
        return readyButton
    }
    
    private func makeCategoryNameTextField() -> UITextField {
        let categoryNameTextField = UITextField()
        
        let categoryNameTextFieldPlaceholder = NSLocalizedString("placeholder_of_categoryNameTextField_on_newCategory_page", comment: "")
        
        categoryNameTextField.placeholder = categoryNameTextFieldPlaceholder
        categoryNameTextField.backgroundColor = .ypBackground
        categoryNameTextField.layer.cornerRadius = 16
        categoryNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        categoryNameTextField.delegate = self
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return categoryNameTextField
    }
    
    private func updateReadyButtonState() {
        let shouldBeActive = isTextFieldFilled
        
        readyButton.isEnabled = shouldBeActive
        UIView.animate(withDuration: 0.3) {
            self.readyButton.backgroundColor = shouldBeActive ? .ypBlack : .ypGray
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let textOfButtonOnErrorAlert = NSLocalizedString("text_of_button_on_error_alert_on_newCategory_page", comment: "")
        
        alert.addAction(UIAlertAction(title: textOfButtonOnErrorAlert, style: .default))
        present(alert, animated: true)
    }
    
}

