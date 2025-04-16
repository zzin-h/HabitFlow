//
//  UpdateHabitRecordUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

protocol UpdateHabitRecordUseCase {
    func execute(recordId: UUID, newDate: Date, newDuration: Int32) -> AnyPublisher<Void, Error>
}

final class DefaultUpdateHabitRecordUseCase: UpdateHabitRecordUseCase {
    private let repository: HabitRecordRepository

    init(repository: HabitRecordRepository) {
        self.repository = repository
    }

    func execute(recordId: UUID, newDate: Date, newDuration: Int32) -> AnyPublisher<Void, Error> {
        return repository.updateRecord(id: recordId, date: newDate, duration: Int32(newDuration))
    }
}
