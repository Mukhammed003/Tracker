//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 17.08.2025.
//

import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDelegate {
    
    var trackerRecord1 = Tracker(id: 834920171, name: "Бабушка прислала открытку в вотсапе", color: UIColor(resource: .ypBlue), emoji: "❤️", schedule: [.friday, .saturday, .wednesday])
    var trackerRecord2 = Tracker(id: 834920172, name: "Комп", color: UIColor(resource: .colorSelection11), emoji: "😻", schedule: [.monday])
    var trackerRecord3 = Tracker(id: 834920173, name: "Кошка", color: UIColor(resource: .colorSelection5), emoji: "🌺", schedule: [.wednesday])
    var trackerRecord4 = Tracker(id: 834920174, name: "Собака", color: UIColor(resource: .colorSelection7), emoji: "😡", schedule: [.friday])
    var trackerRecord5 = Tracker(id: 834920175, name: "Мышь", color: UIColor(resource: .colorSelection10), emoji: "🙌", schedule: [.friday, .wednesday])
    var trackerRecord6 = Tracker(id: 834920176, name: "Холодильник", color: UIColor(resource: .colorSelection13), emoji: "😪", schedule: [.tuesday, .saturday, .wednesday])
    var trackerRecord7 = Tracker(id: 834920177, name: "Пасуда", color: UIColor(resource: .colorSelection6), emoji: "🎸", schedule: [.friday, .saturday])
    var trackerRecord8 = Tracker(id: 834920178, name: "Сосед", color: UIColor(resource: .colorSelection1), emoji: "🏝", schedule: [.sunday])
    
    lazy var listOfTRackers1: [Tracker] = [trackerRecord1, trackerRecord2, trackerRecord3]
    lazy var listOfTRackers2: [Tracker] = [trackerRecord4, trackerRecord5]
    lazy var listOfTRackers3: [Tracker] = [trackerRecord6, trackerRecord7, trackerRecord8]
    
    lazy var record1 = TrackerCategory(header: "На завтра", listOfTrackers: listOfTRackers1)
    lazy var record2 = TrackerCategory(header: "Сегодня", listOfTrackers: listOfTRackers2)
    lazy var record3 = TrackerCategory(header: "Когда закончу школу", listOfTrackers: listOfTRackers3)
    
    private lazy var categories: [TrackerCategory] = [record1, record2, record3]
    private var completedTrackers: Set<TrackerRecord> = []
    private var needTrackersByDate: [TrackerCategory] = []
    private var currentDate: Date = Date()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var addTrackerButton: UIButton = makeAddTrackerButton()
    private lazy var datePicker: UIDatePicker = makeDatePicker()
    private lazy var searchField: UISearchController = makeSearchField()
    private lazy var splashContainerView: UIView = makeSplashContainerView()
    private lazy var notFoundImage: UIImageView = makeNotFoundImage()
    private lazy var notFoundLabel: UILabel = makeNotFoundLabel()
    
//    private var completeTrackerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavBar()
        setupCollectionView()
        setupSplashView()
        
        filterTrackersByDate()
        showNeedScreen()
    }
    
    func handlerForTrackerCompletion(trackerID: UInt, isCompleted: Bool) {
        if isCompleted {
            trackerCompleted(trackerID: trackerID)
        } else {
            trackerUncompleted(trackerID: trackerID)
        }
        
        for (sectionIndex, trackerCategory) in needTrackersByDate.enumerated() {
            if let rowIndex = trackerCategory.listOfTrackers.firstIndex(where: {$0.id == trackerID}) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                collectionView.reloadItems(at: [indexPath])
                break
            }
        }
    }
    
    @objc private func clickToAddTrackerButton() {
        let newHabitVc = NewHabitViewController()
        newHabitVc.categories = self.categories
        let navController = UINavigationController(rootViewController: newHabitVc)
        navController.modalPresentationStyle = .pageSheet
        
        newHabitVc.onCreate = { [weak self] trackerCategory in
            guard let self = self else { return }
            
            if !trackerCategory.isEmpty {
                
                let newTrackerCategory = trackerCategory[0]
                
                if let index = categories.firstIndex(where: {$0.header == newTrackerCategory.header}) {
                    
                    let existingCategory = categories[index]
                    let updatedTrackers = existingCategory.listOfTrackers + newTrackerCategory.listOfTrackers
                    
                    let updatedCategory = TrackerCategory(header: existingCategory.header, listOfTrackers: updatedTrackers)
                    
                    categories = categories.enumerated().map { idx, cat in
                        return idx == index ? updatedCategory : cat
                    }
                    print("Обновили существующую категорию: \(categories)")
                } else {
                    categories = categories + [newTrackerCategory]
                    print("Добавили новую категорию: \(categories)")
                }
            }
            filterTrackersByDate()
            showNeedScreen()
        }
        
        present(navController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        
        filterTrackersByDate()
        showNeedScreen()
    }
    
    private func showNeedScreen() {
        if needTrackersByDate.isEmpty {
            splashContainerView.isHidden = false
            collectionView.isHidden = true
        } else {
            splashContainerView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }
    
    private func setupNavBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.searchController = searchField
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupSplashView() {
        
        splashContainerView.translatesAutoresizingMaskIntoConstraints = false
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
            
            notFoundLabel.leadingAnchor.constraint(equalTo: splashContainerView.leadingAnchor, constant: 16),
            notFoundLabel.topAnchor.constraint(equalTo: notFoundImage.bottomAnchor, constant: 8),
            notFoundLabel.trailingAnchor.constraint(equalTo: splashContainerView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: Constants.trackerCollectionViewCellIdentifier
        )
        
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func makeAddTrackerButton() -> UIButton {
        let addTrackerButton = createUIButton(imageForButton: "plus", forSelector: #selector(clickToAddTrackerButton), colorOfIcon: .black)
        
        return addTrackerButton
    }
    
    private func makeDatePicker() -> UIDatePicker {
        let datePicker = createDatePicker()
        
        return datePicker
    }
    
    private func makeSearchField() -> UISearchController {
        let searchField = createSearchTextField(placeholderText: "Поиск")
        
        return searchField
    }
    
    private func makeNotFoundImage() -> UIImageView {
        let notFoundImage = createUIImageView(
            nameOfImage: .notFound,
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
    
    private func makeSplashContainerView() -> UIView {
        let splashContainerView = UIView()
        
        return splashContainerView
    }
    
    private func createUIImageView(nameOfImage imageResource: ImageResource, radiusIfNeeded cornerRadius: CGFloat) -> UIImageView {
        let exampleImage = UIImage(resource: imageResource)
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
    
    private func createDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        return datePicker
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
    
    private func trackerCompleted(trackerID: UInt) {
        
        let selectedDate = currentDate
        let todaysDate = Date()
        
        if selectedDate > todaysDate {
            print("Нельзя добавлять будущие даты")
            print(completedTrackers)
            return
        }
        
        let trackerRecord = TrackerRecord(id: trackerID, date: selectedDate)
        completedTrackers.insert(trackerRecord)
        
        print("Трекер с ID: \(trackerID) добавлен в выполненные")
        print(completedTrackers)
    }
    
    private func trackerUncompleted(trackerID: UInt) {
        
        print("Трекер с ID: \(trackerID) вычеркнут из выполненных")
        
        let selectedDate = currentDate
        let trackerRecord = TrackerRecord(id: trackerID, date: selectedDate)
        completedTrackers.remove(trackerRecord)
        
        print(completedTrackers)
    }
    
    private func filterTrackersByDate() {
        let needDate = currentDate
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE"
        let weekDay = formatter.string(from: needDate)
        
        var needTrackerCategory: [TrackerCategory] = []
        
        for trackerCategory in categories {
            
            let filteredTrackers = trackerCategory.listOfTrackers.filter { tracker in
                guard let schedule = tracker.schedule else { return false }
                return schedule.contains( where: {$0.rawValue == weekDay} )
            }
            
            if !filteredTrackers.isEmpty {
                needTrackerCategory.append(TrackerCategory(header: trackerCategory.header, listOfTrackers: filteredTrackers))
            }
        }
        
        needTrackersByDate = needTrackerCategory
    }
}


extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return needTrackersByDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return needTrackersByDate[section].listOfTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.trackerCollectionViewCellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let tracker = needTrackersByDate[indexPath.section].listOfTrackers[indexPath.row]
        
        let selectedDate = currentDate
        let trackerRecord = TrackerRecord(id: tracker.id, date: selectedDate)
        let isCompleted: Bool = completedTrackers.contains(trackerRecord)
        
        let count = completedTrackers.filter( {$0.id == tracker.id} ).count
        
        cell.configure(tracker: tracker, isCompleted: isCompleted, count: count) { [weak self] trackerID, isCompletedTracker in
            self?.handlerForTrackerCompletion(trackerID: trackerID, isCompleted: isCompletedTracker)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        view.titleLabel.text = needTrackersByDate[indexPath.section].header
        return view
    } 
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let itemsPerRow: CGFloat = 2
        
        let totalSpacing = spacing * (itemsPerRow - 1)
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = availableWidth / itemsPerRow
        
        return CGSize(width: cellWidth, height: 148)
        }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 12, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,  referenceSizeForHeaderInSection section: Int) -> CGSize { return CGSize(width: collectionView.bounds.width, height: 18)
    }
}
