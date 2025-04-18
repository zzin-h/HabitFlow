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

    // MARK: - Use Cases
    private let fetchTotalCompletedCountUseCase: FetchTotalCompletedCountUseCase
    private let fetchActiveDaysUseCase: FetchActiveDaysUseCase
    private let fetchFavoriteCategoryUseCase: FetchFavoriteCategoryUseCase
    private let fetchBestHabitUseCase: FetchBestHabitUseCase
    private let fetchTotalTimeUseCase: FetchTotalTimeUseCase

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        fetchTotalCompletedCountUseCase: FetchTotalCompletedCountUseCase,
        fetchActiveDaysUseCase: FetchActiveDaysUseCase,
        fetchFavoriteCategoryUseCase: FetchFavoriteCategoryUseCase,
        fetchBestHabitUseCase: FetchBestHabitUseCase,
        fetchTotalTimeUseCase: FetchTotalTimeUseCase
    ) {
        self.fetchTotalCompletedCountUseCase = fetchTotalCompletedCountUseCase
        self.fetchActiveDaysUseCase = fetchActiveDaysUseCase
        self.fetchFavoriteCategoryUseCase = fetchFavoriteCategoryUseCase
        self.fetchBestHabitUseCase = fetchBestHabitUseCase
        self.fetchTotalTimeUseCase = fetchTotalTimeUseCase

        loadStatistics()
    }

    // MARK: - Load Data
    func loadStatistics() {
        fetchTotalCompletedCount()
        fetchActiveDays()
        fetchFavoriteCategory()
        fetchBestHabit()
        fetchTotalTimeSpent()
    }

    private func fetchTotalCompletedCount() {
        fetchTotalCompletedCountUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] count in
                self?.totalCompletedCount = count
            }
            .store(in: &cancellables)
    }

    private func fetchActiveDays() {
        fetchActiveDaysUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] result in
                self?.activeDays = result.total
                self?.streakDays = result.streak
            }
            .store(in: &cancellables)
    }

    private func fetchFavoriteCategory() {
        fetchFavoriteCategoryUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] category in
                self?.favoriteCategory = category
            }
            .store(in: &cancellables)
    }

    private func fetchBestHabit() {
        fetchBestHabitUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] habit in
                self?.bestHabitTitle = habit
            }
            .store(in: &cancellables)
    }

    private func fetchTotalTimeSpent() {
        fetchTotalTimeUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { [weak self] time in
                self?.totalTimeSpent = time
            }
            .store(in: &cancellables)
    }
}
