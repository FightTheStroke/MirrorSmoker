//
//  DateQueryHelpers.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 02/09/25.
//

import Foundation
import SwiftData

// MARK: - Date Range Query Helpers
struct DateQueryHelpers {
    
    static func startOfDay(for date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    static func endOfDay(for date: Date = Date()) -> Date {
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay(for: date)) else {
            // Fallback to 23:59:59 of the same day
            return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
        }
        return endOfDay
    }
    
    static func weekAgo(from date: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .day, value: -7, to: date) ?? date
    }
    
    static func monthAgo(from date: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .month, value: -1, to: date) ?? date
    }
    
    static func thirtyDaysAgo(from date: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .day, value: -30, to: date) ?? date
    }
    
    static func yesterday(from date: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
    }
}

// MARK: - SwiftData Predicates for Cigarettes
extension DateQueryHelpers {
    
    // Today's cigarettes predicate
    static func todayPredicate() -> Predicate<Cigarette> {
        let today = startOfDay()
        let tomorrow = endOfDay()
        return #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= today && cigarette.timestamp < tomorrow
        }
    }
    
    // Yesterday's cigarettes predicate
    static func yesterdayPredicate() -> Predicate<Cigarette> {
        let yesterdayDate = yesterday()
        let startOfYesterday = startOfDay(for: yesterdayDate)
        let endOfYesterday = endOfDay(for: yesterdayDate)
        return #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= startOfYesterday && cigarette.timestamp < endOfYesterday
        }
    }
    
    // Last week predicate
    static func lastWeekPredicate() -> Predicate<Cigarette> {
        let weekAgoDate = weekAgo()
        return #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= weekAgoDate
        }
    }
    
    // Last month predicate
    static func lastMonthPredicate() -> Predicate<Cigarette> {
        let monthAgoDate = monthAgo()
        return #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= monthAgoDate
        }
    }
    
    // Last 30 days predicate
    static func last30DaysPredicate() -> Predicate<Cigarette> {
        let thirtyDaysAgoDate = thirtyDaysAgo()
        return #Predicate<Cigarette> { cigarette in
            cigarette.timestamp >= thirtyDaysAgoDate
        }
    }
    
    // Generic date range predicate
    static func dateRangePredicate(from startDate: Date, to endDate: Date? = nil) -> Predicate<Cigarette> {
        if let endDate = endDate {
            return #Predicate<Cigarette> { cigarette in
                cigarette.timestamp >= startDate && cigarette.timestamp < endDate
            }
        } else {
            return #Predicate<Cigarette> { cigarette in
                cigarette.timestamp >= startDate
            }
        }
    }
}

// MARK: - Query Execution Helper
extension DateQueryHelpers {
    
    static func fetchCigarettes(
        with predicate: Predicate<Cigarette>?,
        from context: ModelContext,
        sortBy: [SortDescriptor<Cigarette>] = [SortDescriptor(\.timestamp, order: .reverse)]
    ) throws -> [Cigarette] {
        let descriptor = FetchDescriptor<Cigarette>(
            predicate: predicate,
            sortBy: sortBy
        )
        return try context.fetch(descriptor)
    }
    
    static func fetchCigarettesSafely(
        with predicate: Predicate<Cigarette>?,
        from context: ModelContext,
        fallback: [Cigarette] = [],
        sortBy: [SortDescriptor<Cigarette>] = [SortDescriptor(\.timestamp, order: .reverse)]
    ) -> [Cigarette] {
        do {
            return try fetchCigarettes(with: predicate, from: context, sortBy: sortBy)
        } catch {
            // SwiftData query failed, using fallback
            return fallback
        }
    }
}