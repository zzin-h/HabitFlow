//
//  TodayHabitViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

final class TodayHabitViewModel: ObservableObject {
    @Published var todos: [HabitModel] = []
    @Published var completed: [HabitModel] = []

    private let habitRepository: HabitRepository
    private let habitRecordRepository: HabitRecordRepository
    private var cancellables = Set<AnyCancellable>()

    init(habitRepository: HabitRepository, habitRecordRepository: HabitRecordRepository) {
        self.habitRepository = habitRepository
        self.habitRecordRepository = habitRecordRepository
    }

//    func loadHabits(for date: Date) {
//        habitRepository.fetchHabits(for: date)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { completion in
//                    if case let .failure(error) = completion {
//                        print("Error fetching habits for date: \(error)")
//                    }
//                },
//                receiveValue: { [weak self] habits in
//                    guard let self = self else { return }
//                    self.todos = habits
//                    self.completed = []
//                }
//            )
//            .store(in: &cancellables)
//    }

    func loadHabits(for date: Date) {
        let habitsPublisher = habitRepository.fetchHabits(for: date)
        let recordsPublisher = habitRecordRepository.fetchAllRecords()

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
        
        habitRecordRepository.addRecord(
            habitId: record.habit.id,
            date: record.date,
            duration: Int32(record.duration)
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .finished:
                print("✅ Habit record 저장 완료")
            case .failure(let error):
                print("❌ Habit record 저장 실패: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] in
            guard let self = self else { return }
            self.completed.append(habit)
            self.todos.removeAll { $0.id == habit.id }
        }
        .store(in: &cancellables)
    }
}
