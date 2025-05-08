//
//  StatisticsChartsDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation

final class StatisticsChartsDIContainer {
    
    // MARK: - Repository
    private let statisticsChartsRepository: StatisticsChartsRepository
    
    // MARK: - UseCase
    private let statisticsChartsUseCase: StatisticsChartsUseCase
    
    // MARK: - Init
    init() {
        self.statisticsChartsRepository = StatisticsChartsRepository()
        self.statisticsChartsUseCase = StatisticsChartsUseCaseImpl(repository: statisticsChartsRepository)
    }
    
    // MARK: - ViewModel
    func makeStatisticsChartViewModel() -> StatisticsChartViewModel {
        return StatisticsChartViewModel(
            useCase: statisticsChartsUseCase
        )
    }
}
