//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 15.09.2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    private var selectedDays: [String] = []

    var onDaysSelected: (([String]) -> Void)?
    
    private let daysOfWeek: [String] = {
        return [
            Constants.mondayFullText,
            Constants.tuesdayFullText,
            Constants.wednesdayFullText,
            Constants.thursdayFullText,
            Constants.fridayFullText,
            Constants.saturdayFullText,
            Constants.sundayFullText]
    }()
    
    private lazy var tableViewWithDaysOfWeek: UITableView = makeTableViewWithDaysOfWeek()
    private lazy var readyButton: UIButton = makeReadyButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let titleSchedulePage = NSLocalizedString("schedule.title", comment: "")
        
        title = titleSchedulePage
        
        setupTableViewWithDaysOfWeek()
        addSubViews()
        addConstraints()
    }
    
    @objc private func switchChanged(_ toggle: UISwitch) {
        let index = toggle.tag
        var shortDay: String = ""
        
        switch index {
        case 0:
            shortDay = DaysOfWeek.monday.localized
        case 1:
            shortDay = DaysOfWeek.tuesday.localized
        case 2:
            shortDay = DaysOfWeek.wednesday.localized
        case 3:
            shortDay = DaysOfWeek.thursday.localized
        case 4:
            shortDay = DaysOfWeek.friday.localized
        case 5:
            shortDay = DaysOfWeek.saturday.localized
        case 6:
            shortDay = DaysOfWeek.sunday.localized
        default:
            break
        }
        
        if toggle.isOn {
            selectedDays.append(shortDay)
        }
        else {
            selectedDays.removeAll() {
                $0 == shortDay
            }
        }
        
        print("Свитч для \(daysOfWeek[index]) изменён: \(toggle.isOn). И обновлён массив с выбранными днями: \(selectedDays)")
    }
    
    @objc private func buttonReadyClicked() {
        if selectedDays.count >= 1 {
            print("Кнопка готово нажата")
            
            sortDaysOfWeek()
            
            onDaysSelected?(selectedDays)
            dismiss(animated: true)
        } else {
            
            let titleOfErrorAlert = NSLocalizedString("schedule.errorAlert.title", comment: "")
            let textOfButtonOnErrorAlert = NSLocalizedString("schedule.errorAlert.buttonText", comment: "")
            
            let alert = UIAlertController(
                title: titleOfErrorAlert,
                message: nil,
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: textOfButtonOnErrorAlert, style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
            print("Надо выбрать хотя бы один день")
        }
    }
    
    private func setupTableViewWithDaysOfWeek() {
        tableViewWithDaysOfWeek.delegate = self
        tableViewWithDaysOfWeek.dataSource = self
        tableViewWithDaysOfWeek.register(UITableViewCell.self, forCellReuseIdentifier: Constants.scheduleTableViewCellIdentifier)
    }
    
    private func addSubViews() {
        [tableViewWithDaysOfWeek, readyButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableViewWithDaysOfWeek.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableViewWithDaysOfWeek.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewWithDaysOfWeek.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewWithDaysOfWeek.heightAnchor.constraint(equalToConstant: 525),
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func makeTableViewWithDaysOfWeek() -> UITableView {
        let tableViewWithDaysOfWeek = UITableView()
        tableViewWithDaysOfWeek.backgroundColor = .ypBackground
        tableViewWithDaysOfWeek.separatorStyle = .singleLine
        tableViewWithDaysOfWeek.layer.cornerRadius = 16
        tableViewWithDaysOfWeek.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 15.0, *) {
            tableViewWithDaysOfWeek.sectionHeaderTopPadding = 0
        }
        tableViewWithDaysOfWeek.tableHeaderView = UIView(frame: .zero)
        
        return tableViewWithDaysOfWeek
    }
    
    private func makeReadyButton() -> UIButton {
        let readyButton = UIButton(type: .custom)
        
        let textOfReadyButton = NSLocalizedString("schedule.readyButton.text", comment: "")
        
        readyButton.setTitle(textOfReadyButton, for: .normal)
        readyButton.setTitleColor(.systemBackground, for: .normal)
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.contentHorizontalAlignment = .center
        readyButton.backgroundColor = .ypBlack
        readyButton.layer.cornerRadius = 16
        readyButton.addTarget(self, action: #selector(buttonReadyClicked), for: .touchUpInside)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        
        return readyButton
    }
    
    private func sortDaysOfWeek() {
        let rightSortedDays: [String] = DaysOfWeek.allCases.map { $0.localized }
        
        let sortedDaysOfWeek = selectedDays.sorted() {
            guard let firstIndex = rightSortedDays.firstIndex(of: $0),
                  let secondIndex = rightSortedDays.firstIndex(of: $1) else {
                return false
            }
            return firstIndex < secondIndex
        }
        
        selectedDays = sortedDaysOfWeek
        
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.scheduleTableViewCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = daysOfWeek[indexPath.row]
        
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.onTintColor = .ypBlue
        toggle.tag = indexPath.row
        toggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        cell.accessoryView = toggle
        cell.backgroundColor = .ypBackground
        
        cell.separatorInset = indexPath.row == daysOfWeek.count - 1
        ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
