//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 15.09.2025.
//

import UIKit

final class NewHabitViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate {
    private let listOfSections: [String] = ["Категория", "Расписание"]
    
    var categories: [TrackerCategory] = []
    
    var onCreate: (([TrackerCategory]) -> Void)?
    
    private var isTextFieldFilled = false
    private var isDaysSelected = false
    private var isEmojiSelected = false
    private var isColorSelected = false
    
    private var needEmoji: String = ""
    private var needColor: UIColor = .systemBackground
    
    private let scrollView = UIScrollView() // For scroll
    private let contentView = UIView() // For scroll
    
    private let collectionViewForEmojis = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let collectionViewForColors = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
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
        setupCollectionViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackerNameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func cancelButtonClicked() {
        print("Кнопка отменить нажата")
        dismiss(animated: true)
    }
    
    @objc private func createButtonClicked() {
        print("Кнопка создать нажата")
        
        guard let trackerNameText = trackerNameTextField.text else {
            return
        }
        
        let selectedDaysOfWeek: [DaysOfWeek]? = returnSelectedDaysOfWeek()
        let newTrackerId: UInt = findTheLastIdOfTracker() + 1
        
        let newTracker: Tracker = Tracker(id: newTrackerId, name: trackerNameText, color: needColor, emoji: needEmoji, schedule: selectedDaysOfWeek)
        let newTrackerCategory: [TrackerCategory] = [TrackerCategory(header: "На завтра", listOfTrackers: [newTracker])]
        
        onCreate?(newTrackerCategory)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        isTextFieldFilled = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        updateCreateButtonState()
    }
    
    private func setupTableViewWithSections() {
        tableViewWithSections.delegate = self
        tableViewWithSections.dataSource = self
//        tableViewWithSections.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        [trackerNameTextField, tableViewWithSections, collectionViewForEmojis, collectionViewForColors, cancelButton, createButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableViewWithSections.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableViewWithSections.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableViewWithSections.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableViewWithSections.heightAnchor.constraint(equalToConstant: 150),
            
            collectionViewForEmojis.topAnchor.constraint(equalTo: tableViewWithSections.bottomAnchor, constant: 50),
            collectionViewForEmojis.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionViewForEmojis.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionViewForEmojis.heightAnchor.constraint(equalToConstant: 204),
            
            collectionViewForColors.topAnchor.constraint(equalTo: collectionViewForEmojis.bottomAnchor, constant: 34),
            collectionViewForColors.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionViewForColors.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionViewForColors.heightAnchor.constraint(equalToConstant: 204),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: collectionViewForColors.bottomAnchor, constant: 16),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.topAnchor.constraint(equalTo: collectionViewForColors.bottomAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupCollectionViews() {
        collectionViewForEmojis.delegate = self
        collectionViewForEmojis.dataSource = self
        collectionViewForEmojis.translatesAutoresizingMaskIntoConstraints = false
        collectionViewForEmojis.allowsMultipleSelection = false
        
        collectionViewForColors.delegate = self
        collectionViewForColors.dataSource = self
        collectionViewForColors.translatesAutoresizingMaskIntoConstraints = false
        collectionViewForEmojis.allowsMultipleSelection = false
        
        collectionViewForEmojis.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: Constants.emojiCollectionViewCellIdentifier
        )
        
        collectionViewForColors.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: Constants.colorCollectionViewCellIdentifier)
        
        collectionViewForEmojis.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Constants.identifierOfHeaderForEmojiCollectionView
        )
        
        collectionViewForColors.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Constants.identifierOfHeaderForColorCollectionView
        )
    }
    
    private func makeTrackerNameTextField() -> UITextField {
        let trackerNameTextField = createUITextField()
        trackerNameTextField.placeholder = "Введите название трекера"
        trackerNameTextField.backgroundColor = .ypBackground
        trackerNameTextField.layer.cornerRadius = 16
        trackerNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        trackerNameTextField.delegate = self
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
        createButton.isEnabled = false
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
        return categories
                    .flatMap({ $0.listOfTrackers })
                    .compactMap({ $0.id })
                    .max()
                ?? 100000
    }
    
    private func returnSelectedDaysOfWeek() -> [DaysOfWeek]? {
        let indexPath: IndexPath = IndexPath(row: 1, section: 0)
        
        guard let selectedDaysOfWeek = tableViewWithSections.cellForRow(at: indexPath)?.detailTextLabel?.text else {
            assertionFailure("Не может быть пустым так как иначе кнопка создать не кликается")
            return nil
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
    
    private func updateCreateButtonState() {
        let shouldBeActive = isDaysSelected && isTextFieldFilled && isEmojiSelected && isColorSelected
        
        createButton.isEnabled = shouldBeActive
        UIView.animate(withDuration: 0.3) {
            self.createButton.backgroundColor = shouldBeActive ? .ypBlack : .ypGray
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewForEmojis {
            needEmoji = NewTrackerSetup.emojis[indexPath.row]
            isEmojiSelected = true
            updateCreateButtonState()
            print("Эмодзи выбран: \(needEmoji)")
        } else {
            needColor = NewTrackerSetup.availableColours[indexPath.row]
            isColorSelected = true
            updateCreateButtonState()
            print("Цвет выбран: \(needColor)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewForEmojis {
            needEmoji = ""
            isEmojiSelected = false
            print("Эмодзи не выбран: \(needEmoji)")
        } else {
            needColor = .systemBackground
            isColorSelected = false
            print("Цвет не выбран: \(needColor)")
        }
    }
    
}

extension NewHabitViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Constants.newHabitTableViewCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: Constants.newHabitTableViewCellIdentifier)
        }
        
        guard let cell = cell else { assertionFailure("Cannot create new cell")
            return UITableViewCell(style: .subtitle, reuseIdentifier: Constants.newHabitTableViewCellIdentifier)}
        
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
                
                self.isDaysSelected = !days.isEmpty
                updateCreateButtonState()
                
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

extension NewHabitViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewForEmojis {
            return NewTrackerSetup.emojis.count
        } else {
            return NewTrackerSetup.availableColours.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewForEmojis {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.emojiCollectionViewCellIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(NewTrackerSetup.emojis[indexPath.row])
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.colorCollectionViewCellIdentifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(NewTrackerSetup.availableColours[indexPath.row])
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if collectionView == collectionViewForEmojis {
                id = Constants.identifierOfHeaderForEmojiCollectionView
            } else {
                id = Constants.identifierOfHeaderForColorCollectionView
            }
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        
        if collectionView == collectionViewForEmojis {
            view.configure(title: "Emoji", leadingInset: 28)
        } else {
            view.configure(title: "Цвет", leadingInset: 28)
        }
        
        return view
    }
}

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
            let spacing: CGFloat = 5
            let totalSpacing = spacing * (itemsPerRow - 1) + 18 + 19 // insets
            let availableWidth = collectionView.frame.width - totalSpacing
            let dynamicWidth = floor(availableWidth / itemsPerRow)
            
            return CGSize(width: min(dynamicWidth, 52), height: 52)
    }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,  referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}
