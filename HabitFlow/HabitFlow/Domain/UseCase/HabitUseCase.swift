//
//  HabitUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import Foundation
import Combine

protocol HabitUseCase {
    func fetchHabits() -> AnyPublisher<[HabitModel], Error>
    func fetchHabits(for date: Date) -> AnyPublisher<[HabitModel], Error>
    func addHabit(_ habit: HabitModel) -> AnyPublisher<Void, Error>
    func deleteHabit(_ id: UUID) -> AnyPublisher<Void, Error>
    func updateHabit(_ habit: HabitModel) -> AnyPublisher<Void, Error>
    
    func updateHabitStatus(_ habitId: UUID, completedAt: Date)
    func addHabitRecord(_ record: HabitRecordModel)
}
