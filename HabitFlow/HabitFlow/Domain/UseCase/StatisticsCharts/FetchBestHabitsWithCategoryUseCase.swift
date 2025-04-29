//
//  FetchBestHabitsWithCategoryUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

import Combine

protocol FetchBestHabitsWithCategoryUseCase {
    func execute() -> AnyPublisher<[String: (count: Int, category: HabitCategory)], Error>
}

final class DefaultFetchBestHabitsWithCategoryUseCase: FetchBestHabitsWithCategoryUseCase {
    private let repository: StatisticsChartsRepository

    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[String: (count: Int, category: HabitCategory)], Error> {
        repository.fetchBestHabitsWithCategory()
            .map { dict in
                dict.sorted { $0.value.count > $1.value.count }
                    .reduce(into: [String: (count: Int, category: HabitCategory)]()) { result, element in
                        result[element.key] = element.value
                    }
            }
            .eraseToAnyPublisher()
    }
}
