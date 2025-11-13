//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 15.09.2025.
//

import UIKit

enum TreckerCreationError: Error {
    case duplicate
}

enum HabitMode {
    case create
    case edit(existingTracker: Tracker, headerOfCategory: String, textCountOfCompletedDays: String)
}

final class NewHabitViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate {
    
    private let mode: HabitMode
    
    private let listOfSections: [String] = {
        
        let textForCategorySection = NSLocalizedString("newHabit.categorySection.text", comment: "")
        let textForScheduleSection = NSLocalizedString("newHabit.scheduleSection.text", comment: "")
        
        return [
            textForCategorySection,
            textForScheduleSection
        ]
    }()
    
    var categories: [TrackerCategory] = []
    
    var isCategoryExists: ((String) -> Bool)?
    var onCreate: (([TrackerCategory], @escaping (Result<Void, TreckerCreationError>) -> Void) -> Void)?
    var onEdit: (([TrackerCategory], String?) -> Void)?
    
    private var isTextFieldFilled = false
    private var isDaysSelected = false
    private var isEmojiSelected = false
    private var isColorSelected = false
    private var isCategorySelected = false
    
    private var oldCategoryName: String? // Update to new category, we need to delete in old category and add to new category
    
    private var selectedEmoji: String? // For edit mode of HabitController
    private var selectedColor: UIColor? // For edit mode of HabitController
    private var selectedCategoryTitle: String? // For edit mode of HabitController
    private var selectedScheduleText: String? // For edit mode of HabitController
    
    private let scrollView = UIScrollView() // For scroll
    private let contentView = UIView() // For scroll
    
    private let collectionViewForEmojis = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let collectionViewForColors = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var editInfoLabel: UILabel = makeEditInfoLabel()
    private lazy var trackerNameTextField: UITextField = makeTrackerNameTextField()
    private lazy var tableViewWithSections: UITableView = makeTableViewWithSections()
    private lazy var cancelButton: UIButton = makeCancelButton()
    private lazy var createButton: UIButton = makeCreateButton()
    
    init(mode: HabitMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let titleOfNewHabitViewController = NSLocalizedString("newHabit.title", comment: "")
        
        title = titleOfNewHabitViewController
        
        setupTableViewWithSections()
        addSubViews()
        addConstraints()
        setupCollectionViews()
        applyMode()
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
        switch mode {
        case .create:
            print("Кнопка создать нажата")
            
            guard let trackerNameText = trackerNameTextField.text else {
                return
            }
            let selectedDaysOfWeek: [DaysOfWeek]? = returnSelectedDaysOfWeek()
            let newTrackerId: UInt = findTheLastIdOfTracker() + 1
            guard let selectedCategoryName = returnCategoryName(),
                  let selectedColor = selectedColor,
                  let selectedEmoji = selectedEmoji else { return }
            
            let newTracker: Tracker =
            Tracker(
                id: newTrackerId,
                name: trackerNameText,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: selectedDaysOfWeek)
            
            let newTrackerCategory: [TrackerCategory] = [
                TrackerCategory(
                    header: selectedCategoryName,
                    listOfTrackers: [newTracker]
                )
            ]
            
            onCreate?(newTrackerCategory) {[weak self] result in
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure(.duplicate):
                    self?.showDuplicateAlert()
                }
            }
        case .edit(let tracker, _, _):
            print("Кнопка сохранить нажата")
            
            guard let trackerNameText = trackerNameTextField.text else {
                return
            }
            let selectedDaysOfWeek: [DaysOfWeek]? = returnSelectedDaysOfWeek()
            guard let selectedCategoryName = returnCategoryName(),
                  let selectedColor = selectedColor,
                  let selectedEmoji = selectedEmoji else { return }
            
            let newTracker: Tracker =
            Tracker(
                id: tracker.id,
                name: trackerNameText,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: selectedDaysOfWeek)
            
            let newTrackerCategory: [TrackerCategory] = [
                TrackerCategory(
                    header: selectedCategoryName,
                    listOfTrackers: [newTracker]
                )
            ]
            
            onEdit?(newTrackerCategory, oldCategoryName)
            self.dismiss(animated: true)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        isTextFieldFilled = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        updateCreateButtonState()
    }
    
    private func applyMode() {
        switch mode {
        case .create:
            let titleOfNewHabitViewController = NSLocalizedString("newHabit.title", comment: "")
            let textOfCreateButton = NSLocalizedString("newHabit.createButton.title", comment: "")
            
            title = titleOfNewHabitViewController
            createButton.setTitle(textOfCreateButton, for: .normal)
            editInfoLabel.isHidden = true
            
        case .edit(let tracker, let headerOfCategory, let textCountOfCompletedDays):
            let titleOfEditHabitViewController = NSLocalizedString("editHabit.title", comment: "")
            let textOfCreateButton = NSLocalizedString("editHabit.saveButton.title", comment: "")
            
            title = titleOfEditHabitViewController
            createButton.setTitle(textOfCreateButton, for: .normal)
            editInfoLabel.isHidden = false
            
            let textOfScheduleDays = makeDaysOfWeekText(from: tracker.schedule)
            
            editInfoLabel.text = textCountOfCompletedDays
            trackerNameTextField.text = tracker.name
            
            selectedEmoji = tracker.emoji
            selectedColor = tracker.color
            selectedCategoryTitle = headerOfCategory
            selectedScheduleText = textOfScheduleDays
            
            oldCategoryName = headerOfCategory // If category will change, we need delete tracker in old category and create in new category
            
            collectionViewForEmojis.reloadData()
            collectionViewForColors.reloadData()
            
            isTextFieldFilled = true
            isDaysSelected = true
            isEmojiSelected = true
            isColorSelected = true
            isCategorySelected = true
            updateCreateButtonState()
        }
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
        
        [editInfoLabel, trackerNameTextField, tableViewWithSections, collectionViewForEmojis, collectionViewForColors, cancelButton, createButton].forEach {
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
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        if case .edit = mode {
            NSLayoutConstraint.activate([
                editInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                editInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                editInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                trackerNameTextField.topAnchor.constraint(equalTo: editInfoLabel.bottomAnchor, constant: 40)
            ])
        } else {
            NSLayoutConstraint.activate([
                trackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
            ])
        }
            NSLayoutConstraint.activate([
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
        collectionViewForColors.allowsMultipleSelection = false
        
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
    
    private func makeEditInfoLabel() -> UILabel {
        let editInfoLabel = UILabel()
        
        editInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        editInfoLabel.textColor = .ypBlack
        editInfoLabel.font = .systemFont(ofSize: 32, weight: .bold)
        editInfoLabel.textAlignment = .center
        
        return editInfoLabel
    }
    
    private func makeTrackerNameTextField() -> UITextField {
        let trackerNameTextField = UITextField()
        
        let trackerNameTextFieldPlaceholder = NSLocalizedString("newHabit.textField.placeholder", comment: "")
        
        trackerNameTextField.placeholder = trackerNameTextFieldPlaceholder
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
        let tableViewWithSections = UITableView()
        tableViewWithSections.backgroundColor = .ypBackground
        tableViewWithSections.separatorStyle = .singleLine
        tableViewWithSections.layer.cornerRadius = 16
        tableViewWithSections.translatesAutoresizingMaskIntoConstraints = false
        
        return tableViewWithSections
    }
    
    private func makeCancelButton() -> UIButton {
        let cancelButton = UIButton(type: .custom)
        
        let textOfCancelButton = NSLocalizedString("newHabit.cancelButton.title", comment: "")
        
        cancelButton.setTitle(textOfCancelButton, for: .normal)
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
        let createButton = UIButton(type: .custom)
        
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
    
    private func findTheLastIdOfTracker() -> UInt {
        return categories
                    .flatMap{ $0.listOfTrackers }
                    .compactMap{ $0.id }
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
        case Constants.allDaysText:
            daysOfWeek = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        case Constants.workingDaysText:
            daysOfWeek = [.monday, .tuesday, .wednesday, .thursday, .friday]
        case Constants.weekendDaysText:
            daysOfWeek = [.saturday, .sunday]
        default:
            daysOfWeek = selectedDaysOfWeek
                .components(separatedBy: ", ")
                .compactMap{ DaysOfWeek.fromLocalized($0) }
        }
        
        return daysOfWeek
    }
    
    private func returnCategoryName() -> String? {
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        
        guard let selectedCategoryName = tableViewWithSections.cellForRow(at: indexPath)?.detailTextLabel?.text else {
            assertionFailure("Не может быть пустым так как иначе кнопка создать не кликается")
            return nil
        }
        
        return selectedCategoryName
    }
    
    private func updateCreateButtonState() {
        let shouldBeActive = isCategorySelected && isDaysSelected && isTextFieldFilled && isEmojiSelected && isColorSelected
        
        createButton.isEnabled = shouldBeActive
        UIView.animate(withDuration: 0.3) {
            self.createButton.backgroundColor = shouldBeActive ? .ypBlack : .ypGray
        }
    }
    
    private func showDuplicateAlert() {
        
        let titleOfErrorAlert = NSLocalizedString("newHabit.errorAlert.title", comment: "")
        let messageOfErrorAlert = NSLocalizedString("newHabit.errorAlert.message", comment: "")
        let textOfButtonOnErrorAlert = NSLocalizedString("newHabit.errorAlert.buttonText", comment: "")
        
        let alert = UIAlertController(
            title: titleOfErrorAlert,
            message: messageOfErrorAlert,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: textOfButtonOnErrorAlert, style: .default))
        present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewForEmojis {
            selectedEmoji = NewTrackerSetup.emojis[indexPath.row]
            isEmojiSelected = true
            updateCreateButtonState()
            print("Эмодзи выбран: \(String(describing: selectedEmoji))")
        } else {
            selectedColor = NewTrackerSetup.availableColours[indexPath.row]
            isColorSelected = true
            updateCreateButtonState()
            print("Цвет выбран: \(String(describing: selectedColor))")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewForEmojis {
            selectedEmoji = ""
            isEmojiSelected = false
            print("Эмодзи не выбран: \(String(describing: selectedEmoji))")
        } else {
            selectedColor = .systemBackground
            isColorSelected = false
            print("Цвет не выбран: \(String(describing: selectedEmoji))")
        }
    }
    
    private func makeDaysOfWeekText(from days: [DaysOfWeek]?) -> String? {
        guard let days = days, !days.isEmpty else { return nil }
        
        let allDays: [DaysOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        
        let daySet = Set(days)

        switch daySet {
        case Set(allDays):
            return Constants.allDaysText
        case Set([.monday, .tuesday, .wednesday, .thursday, .friday]):
            return Constants.workingDaysText
        case Set([.saturday, .sunday]):
            return Constants.weekendDaysText
        default:
            return days.map { $0.localized }.joined(separator: ", ")
        }
    }
    
}

extension NewHabitViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listOfSections.count
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
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategoryTitle
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = selectedScheduleText
        }
        
        cell.separatorInset = indexPath.row == listOfSections.count - 1
        ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            print("Нажали на категорию")
            
            let cateogryStore = TrackerCategoryStore()
            let viewModel = CategoryViewModel(categoryStore: cateogryStore)
            let categoryVc = CategoryViewController(viewModel: viewModel)
            let navVc = UINavigationController(rootViewController: categoryVc)
            navVc.modalPresentationStyle = .pageSheet
            
            categoryVc.onCategorySelected = { [weak self] category in
                guard let self = self else { return }
                
                self.isCategorySelected = !category.isEmpty
                updateCreateButtonState()
                
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.text = category
                    print("Выбранная категория записана в подзаголовок: \(category)")
                }
            }
            
            present(navVc, animated: true)
        case 1:
            print("Нажали на расписание")
            let scheduleVc = ScheduleViewController()
            let navVc = UINavigationController(rootViewController: scheduleVc)
            navVc.modalPresentationStyle = .pageSheet
            
            scheduleVc.onDaysSelected = { [weak self] days in
                guard let self = self else { return }
                
                self.isDaysSelected = !days.isEmpty
                updateCreateButtonState()
                
                let selectedSet = Set(days)
                
                let allDaysSet = Set([
                    DaysOfWeek.monday.localized,
                    DaysOfWeek.tuesday.localized,
                    DaysOfWeek.wednesday.localized,
                    DaysOfWeek.thursday.localized,
                    DaysOfWeek.friday.localized,
                    DaysOfWeek.saturday.localized,
                    DaysOfWeek.sunday.localized
                ])

                let workingDaysSet = Set([
                    DaysOfWeek.monday.localized,
                    DaysOfWeek.tuesday.localized,
                    DaysOfWeek.wednesday.localized,
                    DaysOfWeek.thursday.localized,
                    DaysOfWeek.friday.localized
                ])

                let weekendDaysSet = Set([
                    DaysOfWeek.saturday.localized,
                    DaysOfWeek.sunday.localized
                ])
                
                var daysString: String
                
                if selectedSet == allDaysSet {
                    daysString = Constants.allDaysText
                } else if selectedSet == workingDaysSet {
                    daysString = Constants.workingDaysText
                } else if selectedSet == weekendDaysSet {
                    daysString = Constants.weekendDaysText
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
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == collectionViewForEmojis
        ? NewTrackerSetup.emojis.count
        : NewTrackerSetup.availableColours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewForEmojis {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.emojiCollectionViewCellIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let emoji = NewTrackerSetup.emojis[indexPath.row]
            cell.configure(emoji)
            
            if emoji == selectedEmoji {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                cell.isSelected = true
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.colorCollectionViewCellIdentifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let color = NewTrackerSetup.availableColours[indexPath.row]
            cell.configure(color)
            
            if let selectedColor = selectedColor, color.cgColor == selectedColor.cgColor {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                cell.isSelected = true
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = collectionView == collectionViewForEmojis
            ? Constants.identifierOfHeaderForEmojiCollectionView
            : Constants.identifierOfHeaderForColorCollectionView
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        
        let headerTextOfCollectionViewForEmojis = NSLocalizedString("newHabit.emojiCollection.header", comment: "")
        let headerTextOfCollectionViewForColors = NSLocalizedString("newHabit.colorCollection.header", comment: "")
        
        view.configure(title: collectionView ==
                       collectionViewForEmojis
                       ? headerTextOfCollectionViewForEmojis
                       : headerTextOfCollectionViewForColors,
                       leadingInset: 28)
        
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
        5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,  referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
}
