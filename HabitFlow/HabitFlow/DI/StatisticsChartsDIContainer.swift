//
//  StatisticsChartsDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation

final class StatisticsChartsDIContainer {
    
    // MARK: - CoreData Storages
    private let statisticsChartsStorage: StatisticsChartsCoreDataStorage
    
    // MARK: - Repositories
    private let statisticsChartsRepository: StatisticsChartsRepository
    
    // MARK: - Init
    init() {
        self.statisticsChartsStorage = StatisticsChartsCoreDataStorage()
        self.statisticsChartsRepository = StatisticsChartsRepositoryImpl(storage: statisticsChartsStorage)
    }
    
    // MARK: - UseCases
    func makeFetchTotalCompletedStatsUseCase() -> FetchTotalCompletedStatsUseCase {
        return DefaultFetchTotalCompletedStatsUseCase(repository: statisticsChartsRepository)
    }
    
    func makeFetchActiveDaysStatUseCase() -> FetchActiveDaysStatUseCase {
        DefaultFetchActiveDaysStatUseCase(repository: statisticsChartsRepository)
    }
    
    func makeFetchCompletedDatesUseCase() -> FetchCompletedDatesUseCase {
        DefaultFetchCompletedDatesUseCase(repository: statisticsChartsRepository)
    }
    
    func makeFetchBestHabitsWithCategoryUseCase() -> FetchBestHabitsWithCategoryUseCase {
        DefaultFetchBestHabitsWithCategoryUseCase(repository: statisticsChartsRepository)
    }
    
    // MARK: - ViewModel
    func makeStatisticsChartViewModel() -> StatisticsChartViewModel {
        return StatisticsChartViewModel(
            fetchTotalCompletedStatsUseCase: makeFetchTotalCompletedStatsUseCase(),
            fetchActiveDaysStatUseCase: makeFetchActiveDaysStatUseCase(),
            fetchCompletedDatesUseCase: makeFetchCompletedDatesUseCase(),
            fetchBestHabitsWithCategoryUseCase: makeFetchBestHabitsWithCategoryUseCase()
        )
    }
}
