//
//  StatisticsChartsUseCaseImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import Combine

final class StatisticsChartsUseCaseImpl: StatisticsChartsUseCase {
    private let repository: StatisticsChartsRepository
    
    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }
    
    func fetchTotalCompletedStats() -> AnyPublisher<[TotalCompletedStat], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }
            
            do {
                let stats = try self.repository.fetchTotalCompletedStats()
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
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }
            
            do {
                let stat = try self.repository.fetchActiveDaysStat()
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
                let dates = try self.repository.fetchCompletedDates()
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
                let categoryStat = try self.repository.fetchCategoryStats()
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
                let habitCountDict = try self.repository.fetchBestHabitsWithCategory()
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
                let totalTimeStat = try self.repository.fetchTotalTimeStat()
                promise(.success(totalTimeStat))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchTimePatternStat() -> AnyPublisher<TimePatternStat, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            do {
                let timePatternStat = try self.repository.fetchTimePatternStat()
                promise(.success(timePatternStat))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchSummary() -> AnyPublisher<RoutineSummary, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            do {
                let summary = try self.repository.fetchSummary(for: Period.weekly(Date()))
                promise(.success(summary))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
