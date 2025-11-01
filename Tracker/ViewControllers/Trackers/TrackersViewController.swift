//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 17.08.2025.
//

import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDelegate {
    
    private lazy var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var needTrackersByDate: [TrackerCategory] = []
    private var currentDate: Date = Date().startOfDay
    
    private let collectionViewForTrackers = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var addTrackerButton: UIButton = makeAddTrackerButton()
    private lazy var datePicker: UIDatePicker = makeDatePicker()
    private lazy var searchField: UISearchController = makeSearchField()
    private lazy var splashContainerView: UIView = makeSplashContainerView()
    private lazy var notFoundImage: UIImageView = makeNotFoundImage()
    private lazy var notFoundLabel: UILabel = makeNotFoundLabel()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        loadTrackersFromCoreData()
        
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
        
//        for (sectionIndex, trackerCategory) in needTrackersByDate.enumerated() {
//            if let rowIndex = trackerCategory.listOfTrackers.firstIndex(where: {$0.id == trackerID}) {
//                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
//                collectionViewForTrackers.reloadItems(at: [indexPath])
//                break
//            }
//        }
    }
    
    @objc private func clickToAddTrackerButton() {
        let newHabitVc = NewHabitViewController()
        newHabitVc.categories = self.categories
        
        newHabitVc.isCategoryExists = { [weak self] categoryName in
            return self?.trackerCategoryStore.isExistsSuchCategory(withHeader: categoryName) ?? false
            }
        
        let navController = UINavigationController(rootViewController: newHabitVc)
        navController.modalPresentationStyle = .pageSheet
        
        newHabitVc.onCreate = { [weak self] trackerCategory, completion in
            guard let self = self else { return }
            
            let newTrackerCategory = trackerCategory[0]
            let newTracker = newTrackerCategory.listOfTrackers[0]
            
            if trackerCategoryStore.isExistsSuchTrackerInCategory(withHeader: newTrackerCategory.header, withTracker: newTracker.name) {
                completion(.failure(.duplicate))
                return
            }
            
            if let index = categories.firstIndex(where: {$0.header == newTrackerCategory.header}) {
                
                let existingCategory = categories[index]
                let updatedTrackers = existingCategory.listOfTrackers + newTrackerCategory.listOfTrackers
                
                let updatedCategory = TrackerCategory(header: existingCategory.header, listOfTrackers: updatedTrackers)
                
                categories = categories.enumerated().map { idx, cat in
                    idx == index ? updatedCategory : cat
                }
                
                print("Обновили существующую категорию: \(categories)")
                
                trackerCategoryStore.addToExistingTrackerCategory(newTracker: newTrackerCategory.listOfTrackers[0], header: existingCategory.header)
            }
            completion(.success(()))
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
            collectionViewForTrackers.isHidden = true
        } else {
            splashContainerView.isHidden = true
            collectionViewForTrackers.isHidden = false
            collectionViewForTrackers.reloadData()
        }
    }
    
    private func setupNavBar() {
        
        let titleOfNavBarOnTrackersPage = NSLocalizedString("header_of_trackers_page", comment: "")
        
        title = titleOfNavBarOnTrackersPage
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
        collectionViewForTrackers.delegate = self
        collectionViewForTrackers.dataSource = self
        collectionViewForTrackers.translatesAutoresizingMaskIntoConstraints = false
        
        collectionViewForTrackers.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: Constants.trackerCollectionViewCellIdentifier
        )
        
        collectionViewForTrackers.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Constants.identifierOfHeaderForTrackerCollectionView
        )
        
        view.addSubview(collectionViewForTrackers)
        
        NSLayoutConstraint.activate([
            collectionViewForTrackers.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionViewForTrackers.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionViewForTrackers.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionViewForTrackers.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        let placeholderOfSearchField = NSLocalizedString("placeholder_of_searchField_on_trackers_page", comment: "")
        
        let searchField = createSearchTextField(placeholderText: placeholderOfSearchField)
        
        return searchField
    }
    
    private func makeNotFoundImage() -> UIImageView {
        let notFoundImage = createUIImageView(
            nameOfImage: .notFound,
            radiusIfNeeded: 0)
        
        return notFoundImage
    }
    
    private func makeNotFoundLabel() -> UILabel {
        
        let textOfNotFoundLabel = NSLocalizedString("text_of_notFoundLabel_on_trackers_page", comment: "")
        
        let notFoundLabel = createUILabel(
            textOfLabel: textOfNotFoundLabel,
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
        
        let localeIdentifierOfDatePicker = NSLocalizedString("locale_identifier_of_datePicker", comment: "")
        
        datePicker.locale = Locale(identifier: localeIdentifierOfDatePicker)
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
        let todaysDate = Date().startOfDay
        
        if selectedDate > todaysDate {
            print("Нельзя добавлять будущие даты")
            print(completedTrackers)
            return
        }
        
        print("Трекер с ID: \(trackerID) добавлен в выполненные")
        
        guard let trackerCoreData = trackerStore.fetchTrackerById(Int64(trackerID)) else {
            return
        }
        trackerRecordStore.addNewTrackerRecord(tracker: trackerCoreData, date: selectedDate)
        print(trackerRecordStore.debugPrintAllRecords())
    }
    
    private func trackerUncompleted(trackerID: UInt) {
        
        let selectedDate = currentDate
        
        print("Трекер с ID: \(trackerID) вычеркнут из выполненных")
        
        trackerRecordStore.deleteTrackerRecordByIdAndDate(Int64(trackerID), date: selectedDate)
        print(trackerRecordStore.debugPrintAllRecords())
    }
    
    private func filterTrackersByDate() {
        let needDate = currentDate
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: needDate)
        
        let days: [DaysOfWeek] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let selectedDay = days[weekdayIndex - 1]
        
        var needTrackerCategory: [TrackerCategory] = []
        
        for trackerCategory in categories {
            
            let filteredTrackers = trackerCategory.listOfTrackers.filter { tracker in
                guard let schedule = tracker.schedule else { return false }
                return schedule.contains(selectedDay)
            }
                .sorted { $0.id < $1.id }
            
            if !filteredTrackers.isEmpty {
                needTrackerCategory.append(TrackerCategory(header: trackerCategory.header, listOfTrackers: filteredTrackers))
            }
        }
        
        needTrackersByDate = needTrackerCategory.sorted { $0.header < $1.header}
    }
    
    private func loadTrackersFromCoreData() {
        categories = trackerCategoryStore.getAllCategories()
        completedTrackers = Set(trackerRecordStore.getAllRecords())
        
        filterTrackersByDate()
    }
    
    private func reloadDataInCollectionAfterChangingsInCoreData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.loadTrackersFromCoreData()
            self.collectionViewForTrackers.reloadData()
            self.showNeedScreen()
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate, TrackerRecordStoreDelegate, TrackerCategoryStoreDelegate {
    
    func store(_ store: TrackerRecordStore, didUpdate: StoreUpdate) {
        reloadDataInCollectionAfterChangingsInCoreData()
    }
    
    func store(_ store: TrackerCategoryStore, didUpdate: StoreUpdate) {
        reloadDataInCollectionAfterChangingsInCoreData()
    }
    
    func store(_ store: TrackerStore, didUpdate: StoreUpdate) {
        reloadDataInCollectionAfterChangingsInCoreData()
    }
    
}


extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        needTrackersByDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        needTrackersByDate[section].listOfTrackers.count
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
            id = Constants.identifierOfHeaderForTrackerCollectionView
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        view.configure(title: needTrackersByDate[indexPath.section].header, leadingInset: 12)
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
        9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 0, bottom: 12, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,  referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
}


