//
//  Constants.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 26.08.2025.
//

import UIKit

enum DaysOfWeek: String, CaseIterable, Codable {
    case monday = "Пн"
    case tuesday = "Вт"
    case wednesday = "Ср"
    case thursday = "Чт"
    case friday = "Пт"
    case saturday = "Сб"
    case sunday = "Вс"
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
    static let emojiCollectionViewCellIdentifier = "EmojiCollectionViewCell"
    static let colorCollectionViewCellIdentifier = "ColorCollectionViewCell"
    
    static let identifierOfHeaderForTrackerCollectionView = "headerForTrackerCollectionView"
    static let identifierOfHeaderForEmojiCollectionView = "headerForEmojiCollectionView"
    static let identifierOfHeaderForColorCollectionView = "headerForColorCollectionView"
}


