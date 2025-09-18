//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 15.09.2025.
//

import UIKit

final class NewHabitViewController: UIViewController {
    
    private let listOfSections: [String] = ["Категория", "Расписание"]
    
    var categories: [TrackerCategory] = []
    
    var onCreate: (([TrackerCategory]) -> Void)?
    
    private lazy var trackerNameTextField: UITextField = makeTrackerNameTextField()
    private lazy var tableViewWithSections: UITableView = makeTableViewWithSections()
    private lazy var cancelButton: UIButton = makeCancelButton()
    private lazy var createButton: UIButton = makeCreateButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Новая привычка"
        
        setupTableViewWithSections()
        addSubViews()
        addConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackerNameTextField.becomeFirstResponder()
    }
    
    @objc private func cancelButtonClicked() {
        print("Кнопка отменить нажата")
        dismiss(animated: true)
    }
    
    @objc private func createButtonClicked() {
        print("Кнопка создать нажата")
        
        let availableColours: [UIColor] = [
            UIColor(resource: .colorSelection1),
            UIColor(resource: .colorSelection2),
            UIColor(resource: .colorSelection3),
            UIColor(resource: .colorSelection4),
            UIColor(resource: .colorSelection5),
            UIColor(resource: .colorSelection6),
            UIColor(resource: .colorSelection7),
            UIColor(resource: .colorSelection8),
            UIColor(resource: .colorSelection9),
            UIColor(resource: .colorSelection10),
            UIColor(resource: .colorSelection11),
            UIColor(resource: .colorSelection12),
            UIColor(resource: .colorSelection13),
            UIColor(resource: .colorSelection14),
            UIColor(resource: .colorSelection15),
            UIColor(resource: .colorSelection16),
            UIColor(resource: .colorSelection17),
            UIColor(resource: .colorSelection18)
        ]
        
        let emojis: [String] = [
            "🌟", "🔥", "🎯", "🚀", "🌈",
            "💡", "📚", "🧠", "🎉", "💪",
            "😎", "🍀", "☕️", "🎵", "📅",
            "💤", "🏃‍♂️", "📝", "🌞", "🐾"
        ]
        
        let indexPath = IndexPath(row: 1, section: 0)
        
        guard let trackerNameText = trackerNameTextField.text,
              let selectedDaysOfWeekInString = tableViewWithSections.cellForRow(at: indexPath)?.detailTextLabel?.text,
              let color = availableColours.randomElement(),
              let emoji = emojis.randomElement() else {
            return
        }
        
        let selectedDaysOfWeek: [DaysOfWeek] = returnSelectedDaysOfWeek()
        
        if !trackerNameText.isEmpty, !selectedDaysOfWeekInString.isEmpty {
            let newTrackerId: UInt = findTheLastIdOfTracker() + 1
            let newTracker: Tracker = Tracker(id: newTrackerId, name: trackerNameText, color: color, emoji: emoji, schedule: selectedDaysOfWeek)
            
            let newTrackerCategory: [TrackerCategory] = [TrackerCategory(header: "На завтра", listOfTrackers: [newTracker])]
            
            onCreate?(newTrackerCategory)
            dismiss(animated: true)
            
        } else {
            let alert = UIAlertController(
                title: "Надо заполнить все поля",
                message: nil,
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "Понятно", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
            print("Надо заполнить все поля")
        }
    }
    
    private func setupTableViewWithSections() {
        tableViewWithSections.delegate = self
        tableViewWithSections.dataSource = self
//        tableViewWithSections.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func addSubViews() {
        [trackerNameTextField, tableViewWithSections, cancelButton, createButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            trackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableViewWithSections.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableViewWithSections.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewWithSections.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewWithSections.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func makeTrackerNameTextField() -> UITextField {
        let trackerNameTextField = createUITextField()
        trackerNameTextField.placeholder = "Введите название трекера"
        trackerNameTextField.backgroundColor = .ypBackground
        trackerNameTextField.layer.cornerRadius = 16
        trackerNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return trackerNameTextField
    }
    
    private func makeTableViewWithSections() -> UITableView {
        let tableViewWithSections = createTableView()
        tableViewWithSections.backgroundColor = .ypBackground
        tableViewWithSections.separatorStyle = .singleLine
        tableViewWithSections.layer.cornerRadius = 16
        tableViewWithSections.translatesAutoresizingMaskIntoConstraints = false
        
        return tableViewWithSections
    }
    
    private func makeCancelButton() -> UIButton {
        let cancelButton = createUIButton()
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.contentHorizontalAlignment = .center
        cancelButton.backgroundColor = .systemBackground
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderColor = UIColor(resource: .ypRed).cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        return cancelButton
    }
    
    private func makeCreateButton() -> UIButton {
        let createButton = createUIButton()
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.systemBackground, for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.contentHorizontalAlignment = .center
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        return createButton
    }
    
    private func createUITextField() -> UITextField {
        let uITextField = UITextField()
        
        return uITextField
    }
    
    private func createTableView() -> UITableView {
        let uiTableView = UITableView()
        
        return uiTableView
    }
    
    private func createUIButton() -> UIButton {
        let uIButton = UIButton(type: .custom)
        
        return uIButton
    }
    
    private func findTheLastIdOfTracker() -> UInt {
        var maxIdOfTracker: UInt = 0
        
        if categories.isEmpty {
            maxIdOfTracker = 100000
        } else {
            for trackerCategory in categories {
                guard let lastTrackerId = trackerCategory.listOfTrackers.last?.id else { fatalError("Не может быть категории хотя бы без одного трекера") }
                
                if lastTrackerId > maxIdOfTracker {
                    maxIdOfTracker = lastTrackerId
                }
        
            }
        }
        
        return maxIdOfTracker
    }
    
    private func returnSelectedDaysOfWeek() -> [DaysOfWeek] {
        let indexPath: IndexPath = IndexPath(row: 1, section: 0)
        
        guard let selectedDaysOfWeek = tableViewWithSections.cellForRow(at: indexPath)?.detailTextLabel?.text else {
            fatalError("Не может быть пустым так как иначе кнопка создать не кликается")
        }
        
        var daysOfWeek: [DaysOfWeek] = []
        
        switch selectedDaysOfWeek {
        case "Каждый день":
            daysOfWeek = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        case "Рабочие дни":
            daysOfWeek = [.monday, .tuesday, .wednesday, .thursday, .friday]
        case "Выходные дни":
            daysOfWeek = [.saturday, .sunday]
        default:
            daysOfWeek = selectedDaysOfWeek
                .components(separatedBy: ", ")
                .compactMap{ (DaysOfWeek(rawValue: $0)) }
        }
        
        return daysOfWeek
    }
    
}

extension NewHabitViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        guard let cell = cell else { fatalError("Cannot create new cell") }
        
        cell.textLabel?.text = listOfSections[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .ypBackground
        cell.detailTextLabel?.text = ""
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        if indexPath.row == listOfSections.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            print("Нажали на категорию")
        case 1:
            print("Нажали на расписание")
            let scheduleVc = ScheduleViewController()
            let navVc = UINavigationController(rootViewController: scheduleVc)
            navVc.modalPresentationStyle = .pageSheet
            
            scheduleVc.onDaysSelected = { [weak self] days in
                guard let self = self else { return }
                
                let workingDays: [String] = ["Пн", "Вт", "Ср", "Чт", "Пт"]
                let weekendDays: [String] = ["Сб", "Вс"]
                
                var daysString: String
                
                let isWorkingDays = workingDays.allSatisfy { days.contains($0)}
                let isWeekendDays = weekendDays.allSatisfy { days.contains($0)}
                
                if days.count == 7 {
                    daysString = "Каждый день"
                } else if isWorkingDays {
                    daysString = "Рабочие дни"
                } else if isWeekendDays {
                    daysString = "Выходные дни"
                } else {
                    daysString = days.joined(separator: ", ")
                }
                
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = daysString
                    print("Выбранные дни записаны в подзаголовок: \(daysString)")
                }
            }

            present(navVc, animated: true)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
