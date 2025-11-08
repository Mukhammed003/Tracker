//
//  Constants.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 26.08.2025.
//

import UIKit

enum DaysOfWeek: String, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var localized: String {
        NSLocalizedString("daysOfWeek_case_\(rawValue)", comment: "")
    }
}

enum NewTrackerSetup {
    static let availableColours: [UIColor] = [
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
    
    static let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
}

struct StoreUpdate: StoreUpdateProtocol {
    struct Move: MoveProtocol {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

final class Constants {
    static let trackerCollectionViewCellIdentifier = "TrackerCollectionViewCell"
    static let newHabitTableViewCellIdentifier = "NewHabitTableViewCell"
    static let scheduleTableViewCellIdentifier = "ScheduleTableViewCell"
    static let categoryTableViewCellIdentifier = "CategoryTableViewCell"
    static let emojiCollectionViewCellIdentifier = "EmojiCollectionViewCell"
    static let colorCollectionViewCellIdentifier = "ColorCollectionViewCell"
    static let filtersTableViewCellIdentifier = "FilterTableViewCell"
    
    static let identifierOfHeaderForTrackerCollectionView = "headerForTrackerCollectionView"
    static let identifierOfHeaderForEmojiCollectionView = "headerForEmojiCollectionView"
    static let identifierOfHeaderForColorCollectionView = "headerForColorCollectionView"
    
    static let selectedFilterIndex = "selectedFilterIndex"
    
    static let mondayFullText = NSLocalizedString("monday_on_schedule_page", comment: "")
    static let tuesdayFullText = NSLocalizedString("tuesday_on_schedule_page", comment: "")
    static let wednesdayFullText = NSLocalizedString("wednesday_on_schedule_page", comment: "")
    static let thursdayFullText = NSLocalizedString("thursday_on_schedule_page", comment: "")
    static let fridayFullText = NSLocalizedString("friday_on_schedule_page", comment: "")
    static let saturdayFullText = NSLocalizedString("saturday_on_schedule_page", comment: "")
    static let sundayFullText = NSLocalizedString("sunday_on_schedule_page", comment: "")
    
    static let allDaysText = NSLocalizedString("text_for_daysOfWeek_allDays", comment: "")
    static let workingDaysText = NSLocalizedString("text_for_daysOfWeek_workingDays", comment: "")
    static let weekendDaysText = NSLocalizedString("text_for_daysOfWeek_weekendDays", comment: "")
}
