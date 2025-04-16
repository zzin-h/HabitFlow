//
//  UpdateHabitRecordUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

protocol UpdateHabitRecordUseCase {
    func execute(_ updatedRecord: HabitRecordModel) -> AnyPublisher<Void, Error>
}

final class UpdateHabitRecordUseCaseImpl: UpdateHabitRecordUseCase {
    private let repository: HabitRecordRepository

    init(repository: HabitRecordRepository) {
        self.repository = repository
    }

    func execute(_ updatedRecord: HabitRecordModel) -> AnyPublisher<Void, Error> {
        return repository.updateRecord(updatedRecord)
    }
}
