//
//  HabitUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation
import Combine

protocol HabitUseCase {
    func fetchHabits() -> AnyPublisher<[HabitModel], Error>
    func createHabit(habit: HabitModel) -> AnyPublisher<Void, Error>
    func deleteHabit(id: UUID) -> AnyPublisher<Void, Error>
}
