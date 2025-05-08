//
//  TodayHabitViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

final class TodayHabitViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var todos: [HabitModel] = []
    @Published var completed: [HabitModel] = []

    // MARK: - UseCase
    private let habitUseCase: HabitUseCase
    private let habitRecordUseCase: HabitRecordUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(habitUseCase: HabitUseCase, habitRecordUseCase: HabitRecordUseCase) {
        self.habitUseCase = habitUseCase
        self.habitRecordUseCase = habitRecordUseCase
    }
    
    // MARK: - Actions
    func loadHabits(for date: Date) {
        let habitsPublisher = habitUseCase.fetchHabits(for: date)
        let recordsPublisher = habitRecordUseCase.fetchAllRecords()

        Publishers.Zip(habitsPublisher, recordsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("❌ Error loading habits and records: \(error)")
                    }
                },
                receiveValue: { [weak self] (habits, records) in
                    guard let self = self else { return }

                    let completed = habits.filter { habit in
                        records.contains(where: {
                            $0.habit.id == habit.id &&
                            Calendar.current.isDate($0.date, inSameDayAs: date)
                        })
                    }

                    let todos = habits.filter { habit in
                        !completed.contains(where: { $0.id == habit.id })
                    }

                    self.todos = todos
                    self.completed = completed
                }
            )
            .store(in: &cancellables)
    }
    
    func markHabitCompleted(_ habit: HabitModel) {
        let record = HabitRecordModel(
            id: UUID(),
            date: Date(),
            duration: habit.goalMinutes ?? 0,
            habit: habit
        )
        
        habitRecordUseCase.addRecord(
            habitId: record.habit.id,
            date: record.date,
            duration: Int32(record.duration)
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .finished:
                print("✅ \(habit.title) 저장 완료")
            case .failure(let error):
                print("❌ \(habit.title) 저장 실패: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] in
            guard let self = self else { return }
            self.completed.append(habit)
            self.todos.removeAll { $0.id == habit.id }
        }
        .store(in: &cancellables)
    }
}
