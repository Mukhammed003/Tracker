//
//  FIltersViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 08.11.2025.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    var onFilterSelected: ((Int) -> Void)?
    
    private let storage = Storage.shared
    
    private var selectedFilterIndex: Int?
    private let listOfFilters: [String] = {
        
        let textOfAllTrackersSection = NSLocalizedString("text_of_allTrackers_section_on_filters_page", comment: "")
        let textOfForTodaySection = NSLocalizedString("text_of_forToday_section_on_filters_page", comment: "")
        let textOfCompletedSection = NSLocalizedString("text_of_completed_section_on_filters_page", comment: "")
        let textOfUncompletedSection = NSLocalizedString("text_of_uncompleted_section_on_filters_page", comment: "")
        
        return [
            textOfAllTrackersSection,
            textOfForTodaySection,
            textOfCompletedSection,
            textOfUncompletedSection
        ]
    }()
    
    private lazy var tableViewWithFilters: UITableView = makeTableViewWithFilters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let titleOfFiltersViewController = NSLocalizedString("title_of_filtersViewController", comment: "")
        
        title = titleOfFiltersViewController
        
        setupTableViewWithCategories()
        addSubViews()
        
        selectedFilterIndex = storage.loadSelectedFilter()
    }
    
    private func setupTableViewWithCategories() {
        tableViewWithFilters.delegate = self
        tableViewWithFilters.dataSource = self
        tableViewWithFilters.register(UITableViewCell.self, forCellReuseIdentifier: Constants.filtersTableViewCellIdentifier)
    }
    
    private func addSubViews() {
        [tableViewWithFilters].forEach {
            view.addSubview($0)
        }
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableViewWithFilters.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableViewWithFilters.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewWithFilters.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewWithFilters.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func makeTableViewWithFilters() -> UITableView {
        let tableViewWithFilters = UITableView()
        tableViewWithFilters.backgroundColor = .systemBackground
        tableViewWithFilters.separatorStyle = .singleLine
        tableViewWithFilters.layer.cornerRadius = 16
        tableViewWithFilters.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 15.0, *) {
            tableViewWithFilters.sectionHeaderTopPadding = 0
        }
        tableViewWithFilters.tableHeaderView = UIView(frame: .zero)
        
        return tableViewWithFilters
    }

}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.filtersTableViewCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = listOfFilters[indexPath.row]
        
        if selectedFilterIndex == indexPath.row && indexPath.row > 1 {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
        } else {
            cell.accessoryType = .none
        }
        
        cell.backgroundColor = .ypBackground
        
        cell.separatorInset = indexPath.row == listOfFilters.count - 1
        ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilterIndex = indexPath.row
        storage.saveSelectedFilter(index: indexPath.row)
        
        tableView.reloadData()
        print("Ячейка \(indexPath.row) кликнута, фильтр: \(listOfFilters[indexPath.row])")
        
        onFilterSelected?(indexPath.row)
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
