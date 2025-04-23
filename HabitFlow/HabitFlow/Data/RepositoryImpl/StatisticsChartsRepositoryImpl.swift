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
}
