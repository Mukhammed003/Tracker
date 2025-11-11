//
//  StatisticsCalculator.swift
//  Tracker
//
//  Created by Muhammed Nurmukhanov on 11.11.2025.
//

import Foundation

final class StatisticsCalculator {
    
    private let storage = Storage.shared
    
    func calculateEverythingAndSendToUserDefaults(categories: [TrackerCategory], completedTrackers: Set<TrackerRecord>)  {
        let bestPeriod = calculateTheBestPeriod(completedTrackers: completedTrackers, categories: categories)
        let perfectDays = calculateThePerfectDays(categories: categories, completedTrackers: completedTrackers)
        let countOfTrackers = calculateCompletedTrackers(completedTrackers: completedTrackers)
        let averagevalue = calculateAverageValue(completedTrackers: completedTrackers)
        
        storage.saveValuesForStatistics(bestPeriodValue: bestPeriod, perfectDaysValue: perfectDays, completedTrackersValue: countOfTrackers, averageValue: averagevalue)
        
        print("Best period: \(bestPeriod). \n Perfect days: \(perfectDays). \n Completed trackers: \(countOfTrackers). \n Average value: \(averagevalue).")
    }
    
    private func calculateTheBestPeriod(completedTrackers: Set<TrackerRecord>, categories: [TrackerCategory]) -> Double {
        var bestPeriod = 0
        let calendar = Calendar.current
        
        let groupedById = Dictionary(grouping: completedTrackers) { $0.id }
        let sortedByDatePerId = groupedById.mapValues { $0.sorted { $0.date < $1.date } }
        
        for (id, sortedRecords) in sortedByDatePerId {
            guard let weekDays = scheduleForTracker(id: id, categories: categories) else { continue }
            var maxStreak = 0
            var currentStreak = 0
            var previousDate: Date? = nil
            
            for record in sortedRecords {
                if let prevDate = previousDate {
                    var nextAllowedDate: Date? = nil
                    for i in 1...7 {
                        let candidateDate = calendar.date(byAdding: .day, value: i, to: prevDate)!
                        let weekday = calendar.component(.weekday, from: candidateDate)
                        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
                        if weekDays.contains(where: { $0.dayNumber == adjustedWeekday }) {
                            nextAllowedDate = candidateDate
                            break
                        }
                    }
                    
                    if let nextDate = nextAllowedDate,
                       calendar.isDate(record.date, inSameDayAs: nextDate) {
                        currentStreak += 1
                    } else {
                        currentStreak = 1
                    }
                } else {
                    currentStreak = 1
                }
                
                previousDate = record.date
                maxStreak = max(maxStreak, currentStreak)
            }
            
            bestPeriod = max(bestPeriod, maxStreak)
        }
        return Double(bestPeriod)
    }
    
    private func scheduleForTracker(id: UInt, categories: [TrackerCategory]) -> [DaysOfWeek]? {
        for category in categories {
            if let tracker = category.listOfTrackers.first(where: { $0.id == id }) {
                return tracker.schedule
            }
        }
        return nil
    }
    
    private func calculateThePerfectDays(categories: [TrackerCategory], completedTrackers: Set<TrackerRecord>) -> Double {
        var perfectDays: Double = 0
        var dictionaryWeekendDays: [Int: Int] = [1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0]
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        for category in categories {
            for tracker in category.listOfTrackers {
                guard let schedule = tracker.schedule else { continue }
                for day in schedule {
                    let dayNumber = day.dayNumber
                    dictionaryWeekendDays[dayNumber, default: 0] += 1
                }
            }
        }
        
        let groupedByDay = Dictionary(grouping: completedTrackers) {record in
            record.date.startOfDayUTC
        }
        
        groupedByDay.forEach { date, records in
            let weekDay = calendar.component(.weekday, from: date)
            let adjustedWeekDay = weekDay == 1 ? 7 : weekDay - 1
            if dictionaryWeekendDays[adjustedWeekDay] == records.count {
                perfectDays += 1
            }
        }
        
        return perfectDays
    }
    
    private func calculateCompletedTrackers(completedTrackers: Set<TrackerRecord>) -> Double {
        return Double(completedTrackers.count)
    }
    
    private func calculateAverageValue(completedTrackers: Set<TrackerRecord>) -> Double {
        
        let groupedByDay = Dictionary(grouping: completedTrackers) {record in
            record.date.startOfDayUTC
        }
        
        let dailyCounts = groupedByDay.map { $0.value.count }
        guard !dailyCounts.isEmpty else { return 0 }
        let total = dailyCounts.reduce(0, +)
        
        return Double(total) / Double(dailyCounts.count)
    }
    
}
