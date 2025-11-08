//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 25.10.2025.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    var onCategorySelected: ((String) -> Void)?
    
    private let viewModel: CategoryViewModel
    
    private lazy var tableViewWithCategories: UITableView = makeTableViewWithCategories()
    private lazy var splashContainerView: UIView = makeSplashContainerView()
    private lazy var addCategoryButton: UIButton = makeAddCategoryButton()
    private lazy var notFoundImage: UIImageView = makeNotFoundImage()
    private lazy var notFoundLabel: UILabel = makeNotFoundLabel()
    
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let titleOfCategoryViewController = NSLocalizedString("title_of_categoryViewController", comment: "")
        
        title = titleOfCategoryViewController
        
        setupTableViewWithCategories()
        addSubViews()
        setupSplashView()
        
        bindViewModel()
        showNeedScreen()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewWithCategories.layoutIfNeeded()
    }
    
    @objc private func buttonAddCategoryClicked() {
        print("Кнопка добавить категорию нажата")
        
        let newCategoryVc = NewCategoryViewController(viewModel: viewModel)
        
        newCategoryVc.onNewCategoryCreated = { [weak self] newCategory in
            self?.viewModel.addCategory(newCategory)
        }
        
        let navVc = UINavigationController(rootViewController: newCategoryVc)
        navVc.modalPresentationStyle = .pageSheet
        
        present(navVc, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            guard let self else { return }
            self.tableViewWithCategories.reloadData()
            self.showNeedScreen()
        }
    }
    
    private func showNeedScreen() {
        if viewModel.categories.isEmpty {
            splashContainerView.isHidden = false
            tableViewWithCategories.isHidden = true
        } else {
            splashContainerView.isHidden = true
            tableViewWithCategories.isHidden = false
            
            DispatchQueue.main.async {
                self.tableViewWithCategories.layoutIfNeeded()
            }
        }
    }
    
    private func setupTableViewWithCategories() {
        tableViewWithCategories.delegate = self
        tableViewWithCategories.dataSource = self
        tableViewWithCategories.register(UITableViewCell.self, forCellReuseIdentifier: Constants.categoryTableViewCellIdentifier)
    }
    
    private func addSubViews() {
        [tableViewWithCategories, addCategoryButton].forEach {
            view.addSubview($0)
        }
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableViewWithCategories.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableViewWithCategories.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewWithCategories.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewWithCategories.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupSplashView() {
        splashContainerView.translatesAutoresizingMaskIntoConstraints = false
        splashContainerView.isUserInteractionEnabled = false
        view.addSubview(splashContainerView)
        
        splashContainerView.addSubview(notFoundImage)
        splashContainerView.addSubview(notFoundLabel)
        
        NSLayoutConstraint.activate([
            splashContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            splashContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            splashContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splashContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            notFoundImage.heightAnchor.constraint(equalToConstant: 80),
            notFoundImage.widthAnchor.constraint(equalToConstant: 80),
            notFoundImage.centerXAnchor.constraint(equalTo: splashContainerView.centerXAnchor),
            notFoundImage.centerYAnchor.constraint(equalTo: splashContainerView.centerYAnchor),
            
            notFoundLabel.leadingAnchor.constraint(equalTo: splashContainerView.leadingAnchor, constant: 90),
            notFoundLabel.topAnchor.constraint(equalTo: notFoundImage.bottomAnchor, constant: 8),
            notFoundLabel.trailingAnchor.constraint(equalTo: splashContainerView.trailingAnchor, constant: -90)
        ])
    }
    
    private func makeTableViewWithCategories() -> UITableView {
        let tableViewWithCategories = UITableView()
        tableViewWithCategories.backgroundColor = .systemBackground
        tableViewWithCategories.separatorStyle = .singleLine
        tableViewWithCategories.layer.cornerRadius = 16
        tableViewWithCategories.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 15.0, *) {
            tableViewWithCategories.sectionHeaderTopPadding = 0
        }
        tableViewWithCategories.tableHeaderView = UIView(frame: .zero)
        
        return tableViewWithCategories
    }
    
    private func makeAddCategoryButton() -> UIButton {
        let addCategoryButton = UIButton(type: .custom)
        
        let textOfAddCategoryButton = NSLocalizedString("text_of_addCategoryButton_on_category_page", comment: "")
        
        addCategoryButton.setTitle(textOfAddCategoryButton, for: .normal)
        addCategoryButton.setTitleColor(.systemBackground, for: .normal)
        addCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.contentHorizontalAlignment = .center
        addCategoryButton.backgroundColor = .ypBlack
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.addTarget(self, action: #selector(buttonAddCategoryClicked), for: .touchUpInside)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        return addCategoryButton
    }
    
    private func makeSplashContainerView() -> UIView {
        let splashContainerView = UIView()
        
        return splashContainerView
    }
    
    private func makeNotFoundImage() -> UIImageView {
        let notFoundImage = UIImage(resource: .notFound)
        let notFoundImageView = UIImageView(image: notFoundImage)
        notFoundImageView.clipsToBounds = true
        
        notFoundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return notFoundImageView
    }
    
    private func makeNotFoundLabel() -> UILabel {
        let notFoundLabel = UILabel()
        
        notFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        notFoundLabel.numberOfLines = 2
        notFoundLabel.lineBreakMode = .byWordWrapping
        notFoundLabel.textAlignment = .center
        
        let notFoundLabelText = NSLocalizedString("text_of_notFoundLabel_on_category_page", comment: "")
        
        let attributedString = NSAttributedString(
            string: notFoundLabelText,
            attributes: [
                .kern: 0,
                .foregroundColor: UIColor.ypBlack,
                .font: UIFont.systemFont(ofSize: 12, weight: .medium)
            ]
        )
        notFoundLabel.attributedText = attributedString
        
        return notFoundLabel
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryTableViewCellIdentifier, for: indexPath)
        let category = viewModel.categories[indexPath.row]
        
        cell.textLabel?.text = category.header
        
        if viewModel.selectedCategoryIndex == indexPath.row {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
        } else {
            cell.accessoryType = .none
        }
        
        cell.backgroundColor = .ypBackground
        
        cell.separatorInset = indexPath.row == viewModel.categories.count - 1
        ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        tableView.reloadData()
        
        print("Ячейка \(indexPath.row) кликнута, категория: \(viewModel.categories[indexPath.row].header)")
        
        if let selectedCategory = viewModel.selectedCategoryName() {
            onCategorySelected?(selectedCategory)
        }
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
