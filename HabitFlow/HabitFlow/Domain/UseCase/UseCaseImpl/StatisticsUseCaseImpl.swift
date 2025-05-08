//
//  StatisticsUseCaseImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import Combine

final class StatisticsUseCaseImpl: StatisticsUseCase {
    private let repository: StatisticsRepository
    
    init(repository: StatisticsRepository) {
        self.repository = repository
    }
    
    func fetchTotalCompletedCount() -> AnyPublisher<Int, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }

            do {
                let count = try self.repository.fetchTotalCompletedCount()
                promise(.success(count))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchActiveDays() -> AnyPublisher<(total: Int, streak: Int), Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }

            do {
                let result = try self.repository.fetchActiveDays()
                promise(.success(result))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchFavoriteCategory() -> AnyPublisher<String, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }

            do {
                let category = try self.repository.fetchFavoriteCategory()
                promise(.success(category))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchBestHabit() -> AnyPublisher<String, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }

            do {
                let habit = try self.repository.fetchBestHabit()
                promise(.success(habit))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchTotalTime() -> AnyPublisher<Int, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }

            do {
                let time = try self.repository.fetchTotalTime()
                promise(.success(time))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchTimeBasedStats() -> AnyPublisher<TimeBasedStats, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }

            do {
                let result = try self.repository.fetchTimeBasedStats()
                let model = TimeBasedStats(mostFrequentDay: result.mostFrequentDay, mostFrequentTime: result.mostFrequentTime)
                promise(.success(model))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
