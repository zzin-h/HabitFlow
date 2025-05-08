//
//  HabitRecordUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

protocol HabitRecordUseCase {
    func addRecord(habitId: UUID, date: Date, duration: Int32) -> AnyPublisher<Void, Error>
    func deleteRecord(by id: UUID) -> AnyPublisher<Void, Error>
    func updateRecord(id: UUID, date: Date, duration: Int32) -> AnyPublisher<Void, Error>
    func fetchRecords(for habitId: UUID) -> AnyPublisher<[HabitRecordModel], Error>
    func fetchAllRecords() -> AnyPublisher<[HabitRecordModel], Error>
}
