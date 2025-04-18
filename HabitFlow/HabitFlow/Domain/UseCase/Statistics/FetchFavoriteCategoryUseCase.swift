//
//  FetchFavoriteCategoryUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import Combine

protocol FetchFavoriteCategoryUseCase {
    func execute() -> AnyPublisher<String, Error>
}

final class DefaultFetchFavoriteCategoryUseCase: FetchFavoriteCategoryUseCase {
    private let repository: StatisticsRepository

    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<String, Error> {
        return repository.fetchFavoriteCategory()
    }
}
