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
        NSLocalizedString("daysOfWeek.\(rawValue).short", comment: "")
    }
    
    var dayNumber: Int {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
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
    
    static let mondayFullText = NSLocalizedString("schedule.monday", comment: "")
    static let tuesdayFullText = NSLocalizedString("schedule.tuesday", comment: "")
    static let wednesdayFullText = NSLocalizedString("schedule.wednesday", comment: "")
    static let thursdayFullText = NSLocalizedString("schedule.thursday", comment: "")
    static let fridayFullText = NSLocalizedString("schedule.friday", comment: "")
    static let saturdayFullText = NSLocalizedString("schedule.saturday", comment: "")
    static let sundayFullText = NSLocalizedString("schedule.sunday", comment: "")
    
    static let allDaysText = NSLocalizedString("daysOfWeek.allDays", comment: "")
    static let workingDaysText = NSLocalizedString("daysOfWeek.workingDays", comment: "")
    static let weekendDaysText = NSLocalizedString("daysOfWeek.weekendDays", comment: "")
    
    static let desiredOffsetFromFilterButton = CGFloat(16 + 50) // 50 - height of filterButton, 16 - desired offset from filter button
    static let heightOfFourSubviewsAndMarginsBetweenThem = CGFloat(90 * 4 + 12 * 3) // 4 sub views with height 90 and 12 margins between them
}
