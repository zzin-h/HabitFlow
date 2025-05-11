//
//  TodayHabitDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation

final class TodayHabitDIContainer {

    // MARK: - Repository
    private let habitRepository: HabitRepository
    private let habitRecordRepository: HabitRecordRepository

    // MARK: - UseCase
    private let habitUseCase: HabitUseCase
    private let habitRecordUseCase: HabitRecordUseCase

    // MARK: - Init
    init() {
        self.habitRepository = HabitRepository()
        self.habitRecordRepository = HabitRecordRepository()

        self.habitUseCase = HabitUseCaseImpl(
            repository: habitRepository,
            recordRepository: habitRecordRepository
        )
        
        self.habitRecordUseCase = HabitRecordUseCaseImpl(
            repository: habitRecordRepository
        )
    }

    // MARK: - ViewModel
    func makeTodayHabitViewModel() -> TodayHabitViewModel {
        return TodayHabitViewModel(
            habitUseCase: habitUseCase,
            habitRecordUseCase: habitRecordUseCase
        )
    }
}
