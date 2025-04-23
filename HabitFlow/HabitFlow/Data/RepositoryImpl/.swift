//
//  HabitStatRepositoryImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import Combine

final class HabitStatRepositoryImpl: HabitStatRepository {
    private let storage: StatisticsStorage

    init(storage: StatisticsStorage) {
        self.storage = storage
    }

    func fetchTotalCompleted() -> AnyPublisher<[CompletedStat], Error> {
        return storage.fetchTotalCompleted()
    }
}
