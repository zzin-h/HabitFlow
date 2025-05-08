//
//  StatisticsViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import Combine

final class StatisticsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var totalCompletedCount: Int = 0
    @Published var activeDays: Int = 0
    @Published var streakDays: Int = 0
    @Published var favoriteCategory: String = ""
    @Published var bestHabitTitle: String = ""
    @Published var totalTimeSpent: Int = 0
    @Published var mostFrequentDay: String = ""
    @Published var mostFrequentTime: String = ""

    // MARK: - UseCase
    private let useCase: StatisticsUseCase

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        useCase: StatisticsUseCase
    ) {
        self.useCase = useCase

        loadStatistics()
    }

    // MARK: - Load Data
    func loadStatistics() {
        fetchTotalCompletedCount()
        fetchActiveDays()
        fetchFavoriteCategory()
        fetchBestHabit()
        fetchTotalTimeSpent()
        fetchTimeBasedStats() 
    }

    private func fetchTotalCompletedCount() {
        useCase.fetchTotalCompletedCount()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] count in
                self?.totalCompletedCount = count
            }
            .store(in: &cancellables)
    }

    private func fetchActiveDays() {
        useCase.fetchActiveDays()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] result in
                self?.activeDays = result.total
                self?.streakDays = result.streak
            }
            .store(in: &cancellables)
    }

    private func fetchFavoriteCategory() {
        useCase.fetchFavoriteCategory()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] category in
                self?.favoriteCategory = category
            }
            .store(in: &cancellables)
    }

    private func fetchBestHabit() {
        useCase.fetchBestHabit()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] habit in
                self?.bestHabitTitle = habit
            }
            .store(in: &cancellables)
    }

    private func fetchTotalTimeSpent() {
        useCase.fetchTotalTime()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] time in
                self?.totalTimeSpent = time
            }
            .store(in: &cancellables)
    }

    private func fetchTimeBasedStats() {
        useCase.fetchTimeBasedStats()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] result in
                self?.mostFrequentDay = result.mostFrequentDay
                self?.mostFrequentTime = result.mostFrequentTime
            }
            .store(in: &cancellables)
    }
}
