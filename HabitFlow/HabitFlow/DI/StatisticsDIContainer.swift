//
//  StatisticsDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation

final class StatisticsDIContainer {
    
    // MARK: - CoreData Storages
    private let statisticsStorage: StatisticsCoreDataStorage
    
    // MARK: - Repositories
    private let statisticsRepository: StatisticsRepository

    // MARK: - Init
    init() {
        self.statisticsStorage = StatisticsCoreDataStorage()
        self.statisticsRepository = StatisticsRepositoryImpl(storage: statisticsStorage)
    }

    // MARK: - UseCases
    func makeFetchTotalCompletedCountUseCase() -> FetchTotalCompletedCountUseCase {
        return DefaultFetchTotalCompletedCountUseCase(repository: statisticsRepository)
    }

    func makeFetchActiveDaysUseCase() -> FetchActiveDaysUseCase {
        return DefaultFetchActiveDaysUseCase(repository: statisticsRepository)
    }

    func makeFetchFavoriteCategoryUseCase() -> FetchFavoriteCategoryUseCase {
        return DefaultFetchFavoriteCategoryUseCase(repository: statisticsRepository)
    }

    func makeFetchBestHabitUseCase() -> FetchBestHabitUseCase {
        return DefaultFetchBestHabitUseCase(repository: statisticsRepository)
    }

    func makeFetchTotalTimeUseCase() -> FetchTotalTimeUseCase {
        return DefaultFetchTotalTimeUseCase(repository: statisticsRepository)
    }

    // 날짜 기반 통계를 위한 UseCase 추가
    func makeFetchTimeBasedStatsUseCase() -> FetchTimeBasedStatsUseCase {
        return DefaultFetchTimeBasedStatsUseCase(repository: statisticsRepository)
    }

    // MARK: - ViewModel
    func makeStatisticsViewModel() -> StatisticsViewModel {
        return StatisticsViewModel(
            fetchTotalCompletedCountUseCase: makeFetchTotalCompletedCountUseCase(),
            fetchActiveDaysUseCase: makeFetchActiveDaysUseCase(),
            fetchFavoriteCategoryUseCase: makeFetchFavoriteCategoryUseCase(),
            fetchBestHabitUseCase: makeFetchBestHabitUseCase(),
            fetchTotalTimeUseCase: makeFetchTotalTimeUseCase(),
            fetchTimeBasedStatsUseCase: makeFetchTimeBasedStatsUseCase()
        )
    }
}
