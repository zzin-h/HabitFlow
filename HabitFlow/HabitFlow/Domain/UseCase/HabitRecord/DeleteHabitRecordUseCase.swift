//
//  DeleteHabitRecordUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

protocol DeleteHabitRecordUseCase {
    func execute(recordId: UUID) -> AnyPublisher<Void, Error>
}

final class DefaultDeleteHabitRecordUseCase: DeleteHabitRecordUseCase {
    private let repository: HabitRecordRepository

    init(repository: HabitRecordRepository) {
        self.repository = repository
    }

    func execute(recordId: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteRecord(by: recordId)
    }
}
