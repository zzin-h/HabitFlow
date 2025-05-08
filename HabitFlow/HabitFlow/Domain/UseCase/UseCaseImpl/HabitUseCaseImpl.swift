//
//  HabitUseCaseImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import Foundation
import Combine

final class HabitUseCaseImpl: HabitUseCase {
    private let repository: HabitRepository
    private let recordRepository: HabitRecordRepository
    
    init(repository: HabitRepository, recordRepository: HabitRecordRepository) {
        self.repository = repository
        self.recordRepository = recordRepository
    }
    
    func fetchHabits() -> AnyPublisher<[HabitModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }
            do {
                let habits = try self.repository.fetchAllHabits()
                promise(.success(habits))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchHabits(for date: Date) -> AnyPublisher<[HabitModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }

            do {
                let allHabits = try self.repository.fetchAllHabits()
                let filtered = allHabits.filter { $0.isScheduled(for: date) }
                promise(.success(filtered))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addHabit(_ habit: HabitModel) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }
            do {
                try self.repository.addHabit(habit)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteHabit(_ id: UUID) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }
            do {
                try self.repository.deleteHabit(by: id)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateHabit(_ habit: HabitModel) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "repository.deallocated", code: -1)))
                return
            }
            do {
                try self.repository.updateHabit(habit)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateHabitStatus(_ habitId: UUID, completedAt: Date) {
        do {
            try repository.updateHabitStatus(habitId: habitId, completedAt: completedAt)
        } catch {
            print("Error updating habit status: \(error)")
        }
    }
    
    func addHabitRecord(_ record: HabitRecordModel) {
        do {
            try recordRepository.addRecord(
                habitId: record.habit.id,
                date: record.date,
                duration: Int32(record.duration)
            )
        } catch {
            print("Error adding habit record: \(error)")
        }
    }
}
