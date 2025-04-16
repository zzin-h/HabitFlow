//
//  AddHabitRecordUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

protocol AddHabitRecordUseCase {
    func execute(habitId: UUID, date: Date, duration: Int) -> AnyPublisher<Void, Error>
}

final class AddHabitRecordUseCaseImpl: AddHabitRecordUseCase {
    private let repository: HabitRecordRepository

    init(repository: HabitRecordRepository) {
        self.repository = repository
    }

    func execute(habitId: UUID, date: Date, duration: Int) -> AnyPublisher<Void, Error> {
        return repository.addRecord(habitId: habitId, date: date, duration: Int32(duration))
    }
}
