//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 17.08.2025.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private lazy var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var needTrackersByDate: [TrackerCategory] = []
    private var needTrackersForSelector: [TrackerCategory] = []
    private var currentDate: Date = Date().startOfDayUTC
    
    private let collectionViewForTrackers = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var filterButton: UIButton = makeFilterButton()
    private lazy var addTrackerButton: UIButton = makeAddTrackerButton()
    
    private lazy var datePickerView: UIView = makeDatePickerView()
    private lazy var datePicker = UIDatePicker()
    private lazy var datePickerLabel = UILabel()
    
    private lazy var searchField: UISearchController = makeSearchField()
    
    // splash view
    private lazy var splashContainerView: UIView = makeSplashContainerView()
    private lazy var notFoundImage: UIImageView = makeNotFoundImage()
    private lazy var notFoundLabel: UILabel = makeNotFoundLabel()
    
    // nothing not found view
    private lazy var nothingNotFoundView: UIView = makeNothingNotFoundView()
    private lazy var nothingNotFoundImage: UIImageView = makeNothingNotFoundImage()
    private lazy var nothingNotFoundLabel: UILabel = makeNothingNotFoundLabel()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private let storage = Storage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupCoreDataStoresAndLoadData()
        
        setupNavBar()
        setupCollectionView()
        setupSplashView()
        setupNothingNotFoundView()
        
        filterTrackersByDate()
        showNeedScreen()
    }
    
    @objc private func clcickToFilterButton() {
        let filtersVc = FiltersViewController()
        let navController = UINavigationController(rootViewController: filtersVc)
        navController.modalPresentationStyle = .pageSheet
        
        filtersVc.onFilterSelected = { [weak self] index in
            guard let self = self else { return }
            
            switch index {
            case 0:
                choosedAllFilters()
            case 1:
                choosedFiltersForToday()
            case 2:
                choosedCompletedFilters()
            case 3:
                choosedUncompletedFilters()
            default: break
            }
            
        }
        
        present(navController, animated: true)
    }
    
    @objc private func clickToAddTrackerButton() {
        let newHabitVc = NewHabitViewController(mode: .create)
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
            
            if trackerCategoryStore.isExistsSuchTrackerInCategory(
                withHeader: newTrackerCategory.header,
                withTracker: newTracker.name)
            {
                completion(.failure(.duplicate))
                return
            }
            trackerCategoryStore.addToExistingTrackerCategory(newTracker: newTrackerCategory.listOfTrackers[0], header: newTrackerCategory.header)
            
            print("Обновили существующую категорию: \(categories)")
            
            completion(.success(()))
        }
        
        present(navController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        datePickerLabel.text = formatDate(date: sender.date.startOfDayUTC)
        
        currentDate = sender.date.startOfDayUTC
        
        filterTrackersByDate()
        showNeedScreen()
        
        let filterType: Int? = storage.loadSelectedFilter()
        
        switch filterType {
        case 0:
            choosedAllFilters()
        case 1:
            choosedFiltersForToday(overrideDate: false)
        case 2:
            choosedCompletedFilters()
        case 3:
            choosedUncompletedFilters()
        default: break
        }
    }
    
    private func handlerForTrackerCompletion(trackerID: UInt, isCompleted: Bool) {
        if isCompleted {
            trackerCompleted(trackerID: trackerID)
        } else {
            trackerUncompleted(trackerID: trackerID)
        }
    }
    
    private func setupCoreDataStoresAndLoadData() {
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        loadTrackersFromCoreData()
    }
    
    private func showNeedScreen() {
        if needTrackersByDate.isEmpty {
            splashContainerView.isHidden = false
            collectionViewForTrackers.isHidden = true
            filterButton.isHidden = true
            nothingNotFoundView.isHidden = true
        } else {
            splashContainerView.isHidden = true
            collectionViewForTrackers.isHidden = false
            filterButton.isHidden = false
            nothingNotFoundView.isHidden = true
            collectionViewForTrackers.reloadData()
        }
    }
    
    private func showNothingNotFoundView() {
        splashContainerView.isHidden = true
        collectionViewForTrackers.isHidden = true
        filterButton.isHidden = true
        nothingNotFoundView.isHidden = false
    }
    
    private func setupNavBar() {
        
        let titleOfNavBarOnTrackersPage = NSLocalizedString("header_of_trackers_page", comment: "")
        
        title = titleOfNavBarOnTrackersPage
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerView)
        
        navigationItem.searchController = searchField
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupNothingNotFoundView() {
        nothingNotFoundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nothingNotFoundView)
        
        nothingNotFoundView.addSubview(nothingNotFoundImage)
        nothingNotFoundView.addSubview(nothingNotFoundLabel)
        
        NSLayoutConstraint.activate([
            nothingNotFoundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nothingNotFoundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nothingNotFoundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nothingNotFoundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            nothingNotFoundImage.heightAnchor.constraint(equalToConstant: 80),
            nothingNotFoundImage.widthAnchor.constraint(equalToConstant: 80),
            nothingNotFoundImage.centerXAnchor.constraint(equalTo: nothingNotFoundView.centerXAnchor),
            nothingNotFoundImage.centerYAnchor.constraint(equalTo: nothingNotFoundView.centerYAnchor),
            
            nothingNotFoundLabel.leadingAnchor.constraint(equalTo: nothingNotFoundView.leadingAnchor, constant: 16),
            nothingNotFoundLabel.topAnchor.constraint(equalTo: nothingNotFoundImage.bottomAnchor, constant: 8),
            nothingNotFoundLabel.trailingAnchor.constraint(equalTo: nothingNotFoundView.trailingAnchor, constant: -16)
        ])
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
        collectionViewForTrackers.backgroundColor = .ypWhite
        
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
        view.addSubview(filterButton)
        
        collectionViewForTrackers.alwaysBounceVertical = true
        
        collectionViewForTrackers.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 16 + 50, 
                right: 0
            )
        collectionViewForTrackers.scrollIndicatorInsets = collectionViewForTrackers.contentInset
        
        NSLayoutConstraint.activate([
            collectionViewForTrackers.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionViewForTrackers.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionViewForTrackers.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionViewForTrackers.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date.startOfDayUTC)
    }
    
    private func makeFilterButton() -> UIButton {
        let filterButton = UIButton(type: .custom)
        
        let textOfFilterButton = NSLocalizedString("text_of_filterButton_on_trackers_page", comment: "")
        
        filterButton.setTitle(textOfFilterButton, for: .normal)
        filterButton.setTitleColor(.systemBackground, for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        filterButton.contentHorizontalAlignment = .center
        filterButton.backgroundColor = .ypBlue
        filterButton.layer.cornerRadius = 16
        filterButton.addTarget(self, action: #selector(clcickToFilterButton), for: .touchUpInside)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        return filterButton
    }
    
    private func makeAddTrackerButton() -> UIButton {
        let addTrackerButton = createUIButton(imageForButton: "plus", forSelector: #selector(clickToAddTrackerButton), colorOfIcon: .ypBlack)
        
        return addTrackerButton
    }
    
    private func makeDatePickerView() -> UIView {
        let datePicker = createDatePickerView()
        
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
    
    private func makeNothingNotFoundImage() -> UIImageView {
        let nothingNotFoundImage = createUIImageView(
            nameOfImage: .notFoundImage2,
            radiusIfNeeded: 0)
        
        return nothingNotFoundImage
    }
    
    private func makeNothingNotFoundLabel() -> UILabel {
        
        let textOfNothingNotFoundLabel = NSLocalizedString("text_of_nothingNotFoundLabel_on_trackers_page", comment: "")
        
        let nothingNotFoundLabel = createUILabel(
            textOfLabel: textOfNothingNotFoundLabel,
            letterSpacing: 0,
            colorOfLabel: .ypBlack,
            fontSizeOfLabel: 12,
            weightOfLabel: .medium)
        
        nothingNotFoundLabel.textAlignment = .center
        
        return nothingNotFoundLabel
    }
    
    private func makeNothingNotFoundView() -> UIView {
        let nothingNotFoundView = UIView()
        
        return nothingNotFoundView
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
            
        if let buttonImage = UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(weight: .bold)) {
                exampleButton.setImage(buttonImage, for: .normal)
        } else if let buttonImage = UIImage(named: name) {
                exampleButton.setImage(buttonImage, for: .normal)
        }
        
        exampleButton.tintColor = tintColor
        
        exampleButton.translatesAutoresizingMaskIntoConstraints = false
        
        exampleButton.addTarget(self, action: selector, for: .touchUpInside)
        
        return exampleButton
    }
    
    private func createDatePickerView() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        container.layer.cornerRadius = 8
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: NSLocalizedString("locale_identifier_of_datePicker", comment: ""))
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        container.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            datePicker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])
        datePicker.alpha = 0.011
        datePicker.isUserInteractionEnabled = true
        
        // Лейбл с текущей датой
        let dateLabel = UILabel()
        dateLabel.textColor = .black
        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.textAlignment = .center
        dateLabel.text = formatDate(date: Date().startOfDayUTC) // начальная дата
        
        container.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 77),
            container.heightAnchor.constraint(equalToConstant: 34),
            dateLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            dateLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
        ])
        
        self.datePicker = datePicker
        self.datePickerLabel = dateLabel
        
        return container
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
        
        searchController.searchResultsUpdater = self
        
        return searchController
    }
    
    private func trackerCompleted(trackerID: UInt) {
        
        let selectedDate = currentDate
        let todaysDate = Date().startOfDayUTC
        
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
        needTrackersForSelector = needTrackersByDate
    }
    
    private func loadTrackersFromCoreData() {
        categories = trackerCategoryStore.getAllCategories()
        completedTrackers = Set(trackerRecordStore.getAllRecords())
        
        filterTrackersByDate()
    }
    
    private func reloadDataInCollectionAfterChangingsInCoreData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadTrackersFromCoreData()
            self.collectionViewForTrackers.reloadData()
            self.showNeedScreen()
        }
    }
    
    // For context menu process
    
    private func showDeleteAlert(for trackerId: Int64, header: String) {
        
        let titleOfDeleteAlert = NSLocalizedString("title_of_deleteAlert_on_trackerViewController", comment: "")
        let textOfDeleteButton = NSLocalizedString("deleteButton_of_deleteAlert_on_trackerViewController", comment: "")
        let textOfCancelButton = NSLocalizedString("cancelButton_of_deleteAlert_on_trackerViewController", comment: "")
        
        
        let alert = UIAlertController(
            title: titleOfDeleteAlert,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: textOfDeleteButton, style: .destructive) { [weak self] _ in
            self?.deleteTracker(trackerId: trackerId, header: header)
        }
        
        let cancelAction = UIAlertAction(title: textOfCancelButton, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func openEditingPageForTracker(
        tracker: Tracker,
        headerOfCategory: String,
        textCountOfCompletedDays: String
    ) {
        print("Нажали на редактировать в контекстном меню трекера")
        
        let editTrackerVc = NewHabitViewController(
            mode: .edit(
                existingTracker: tracker,
                headerOfCategory: headerOfCategory,
                textCountOfCompletedDays: textCountOfCompletedDays
            )
        )
        
        let navVc = UINavigationController(rootViewController: editTrackerVc)
        navVc.modalPresentationStyle = .pageSheet
        
        editTrackerVc.onEdit = { [weak self] trackerCategory, oldCategoryName in
            guard let self = self else { return }
            
            guard let oldCategoryName = oldCategoryName else { return }
            
            let newTrackerCategory = trackerCategory[0]
            let newTracker = newTrackerCategory.listOfTrackers[0]
                
            self.trackerCategoryStore.updateTrackerInSuchCategory(
                categoryName: newTrackerCategory.header,
                tracker: newTracker,
                oldCategoryName: oldCategoryName)
        }
        
        present(navVc, animated: true)
    }
    
    private func deleteTracker(trackerId: Int64, header: String) {
        trackerCategoryStore.deleteTrackerInSuchCategory(trackerId: trackerId, header: header)
    }
    
    // For filter process
    
    private func choosedAllFilters() {
        needTrackersForSelector = needTrackersByDate
        
        if needTrackersForSelector.isEmpty {
            showNothingNotFoundView()
        }
        
        collectionViewForTrackers.reloadData()
    }
    
    private func choosedFiltersForToday() {
        currentDate = Date().startOfDayUTC
        datePicker.setDate(currentDate, animated: true)
        datePicker.sendActions(for: .valueChanged)
        
        if needTrackersForSelector.isEmpty {
            showNothingNotFoundView()
        }
        
        collectionViewForTrackers.reloadData()
    }
    
    private func choosedCompletedFilters() {
        let selectedDate = currentDate
        
        needTrackersForSelector = needTrackersByDate.compactMap { category in
            let filteredTrackers = category.listOfTrackers.filter { tracker in
                let record = TrackerRecord(id: tracker.id, date: selectedDate)
                return completedTrackers.contains(record)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(header: category.header, listOfTrackers: filteredTrackers)
        }
        
        if needTrackersForSelector.isEmpty {
            showNothingNotFoundView()
        }
        
        collectionViewForTrackers.reloadData()
    }
    
    private func choosedUncompletedFilters() {
        let selectedDate = currentDate
        
        needTrackersForSelector = needTrackersByDate.compactMap { category in
            let filteredTrackers = category.listOfTrackers.filter { tracker in
                let record = TrackerRecord(id: tracker.id, date: selectedDate)
                return !completedTrackers.contains(record)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(header: category.header, listOfTrackers: filteredTrackers)
        }
        
        if needTrackersForSelector.isEmpty {
            showNothingNotFoundView()
        }
        
        collectionViewForTrackers.reloadData()
    }
    
    private func choosedFiltersForToday(overrideDate: Bool = true) {
        if overrideDate {
            currentDate = Date().startOfDayUTC
            datePicker.setDate(currentDate, animated: true)
        }
        
        filterTrackersByDate()
        
        if needTrackersForSelector.isEmpty {
            showNothingNotFoundView()
        }
        
        collectionViewForTrackers.reloadData()
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text,
              !searchText.isEmpty else  {
            collectionViewForTrackers.reloadData()
            return
        }
        
        let lowercasedSearchText = searchText.lowercased()
        
        needTrackersForSelector = needTrackersForSelector.compactMap { category in
            let filteredTrackers = category.listOfTrackers.filter {
                $0.name.lowercased().contains(lowercasedSearchText)
            }
            
            return filteredTrackers.isEmpty
            ? nil
            : TrackerCategory(header: category.header, listOfTrackers: filteredTrackers)
        }
        
        if needTrackersForSelector.isEmpty {
            showNothingNotFoundView()
        }

        collectionViewForTrackers.reloadData()
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
        needTrackersForSelector.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        needTrackersForSelector[section].listOfTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.trackerCollectionViewCellIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let headerOfCategory = needTrackersForSelector[indexPath.section].header
        let tracker = needTrackersForSelector[indexPath.section].listOfTrackers[indexPath.row]
        
        let selectedDate = currentDate
        let trackerRecord = TrackerRecord(id: tracker.id, date: selectedDate)
        let isCompleted: Bool = completedTrackers.contains(trackerRecord)
        
        let count = completedTrackers.filter( {$0.id == tracker.id} ).count
        
        let numberOfDays = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Count of days when trecker is completed"),
            count)
        
        cell.configure(
            tracker: tracker,
            isCompleted: isCompleted,
            count: count,
            completionHandler: { [weak self] trackerID, isCompletedTracker in
                self?.handlerForTrackerCompletion(trackerID: trackerID, isCompleted: isCompletedTracker)
            },
            menuHandler: { [weak self] trackerID, action in
                switch action {
                case .edit:
                    self?.openEditingPageForTracker(tracker: tracker, headerOfCategory: headerOfCategory, textCountOfCompletedDays: numberOfDays)
                case .delete:
                    self?.showDeleteAlert(for: Int64(trackerID), header: headerOfCategory)
                }
            })
        
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
        view.configure(title: needTrackersForSelector[indexPath.section].header, leadingInset: 12)
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


