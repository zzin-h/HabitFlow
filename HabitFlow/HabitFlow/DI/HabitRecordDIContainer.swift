//
//  HabitRecordDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation

final class HabitRecordDIContainer {

    // MARK: - Repository
    private let repository: HabitRecordRepository

    // MARK: - UseCase
    private let useCase: HabitRecordUseCase

    // MARK: - Init
    init() {
        self.repository = HabitRecordRepository()
        self.useCase = HabitRecordUseCaseImpl(repository: repository)
    }

    // MARK: - ViewModel Factory
    func makeHabitRecordViewModel(habitId: UUID) -> HabitRecordViewModel {
        return HabitRecordViewModel(
            habitId: habitId,
            useCase: useCase
        )
    }
}
