//
//  StatisticsChartsRepositoryImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import Combine

final class StatisticsChartsRepositoryImpl: StatisticsChartsRepository {
    private let storage: StatisticsChartsCoreDataStorage
    
    init(storage: StatisticsChartsCoreDataStorage) {
        self.storage = storage
    }
    
    func fetchTotalCompletedStats() -> AnyPublisher<[TotalCompletedStat], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }
            
            do {
                let stats = try self.storage.fetchTotalCompletedStats()
                promise(.success(stats))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchActiveDaysStat() -> AnyPublisher<ActiveDaysStat, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "storage.deallocated", code: -1)))
                return
            }
            
            do {
                let stat = try self.storage.fetchActiveDaysStat()
                promise(.success(stat))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchCompletedDates() -> AnyPublisher<[Date], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            do {
                let dates = try self.storage.fetchCompletedDates()
                promise(.success(dates))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchCategoryStats() -> AnyPublisher<[CategoryStat], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            do {
                let categoryStat = try self.storage.fetchCategoryStats()
                promise(.success(categoryStat))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchBestHabitsWithCategory() -> AnyPublisher<[String: (count: Int, category: HabitCategory)], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            do {
                let habitCountDict = try self.storage.fetchBestHabitsWithCategory()
                promise(.success(habitCountDict))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchTotalTimeStat() -> AnyPublisher<[TotalTimeStat], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            do {
                let totalTimeStat = try self.storage.fetchTotalTimeStat()
                promise(.success(totalTimeStat))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
