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
    @Published var allRecords: [HabitRecordModel] = []
    
    // MARK: - UseCase
    private let habitUseCase: HabitUseCase
    private let habitRecordUseCase: HabitRecordUseCase
    
    private let calendar = Calendar.current
    private var currentDate: Date = Calendar.current.startOfDay(for: Date())
    private let range: Int = 10
    
    private var cancellables = Set<AnyCancellable>()
    // MARK: - Init
    init(habitUseCase: HabitUseCase, habitRecordUseCase: HabitRecordUseCase) {
        self.habitUseCase = habitUseCase
        self.habitRecordUseCase = habitRecordUseCase
    }
    
    // MARK: - Actions
    func loadRecords(for centerDate: Date) {
        habitRecordUseCase.fetchRangeRecords(around: centerDate, range: range)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("❌ Error loading records: \(error)")
                    }
                },
                receiveValue: { [weak self] records in
                    self?.allRecords = records
                }
            )
            .store(in: &cancellables)
    }
    
    func loadHabits(for date: Date) {
        currentDate = calendar.startOfDay(for: date)
        
        let habitsPublisher = habitUseCase.fetchHabits(for: date)
        let recordsPublisher = habitRecordUseCase.fetchRangeRecords(around: date, range: range)
        
        Publishers.CombineLatest(habitsPublisher, recordsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("❌ Error loading habits and records: \(error)")
                    }
                },
                receiveValue: { [weak self] (habits, allRecords) in
                    guard let self = self else { return }
                    
                    let todayRecords = allRecords.filter {
                        self.calendar.isDate($0.date, inSameDayAs: date)
                    }
                    
                    let completed = habits.filter { habit in
                        todayRecords.contains(where: { $0.habit.id == habit.id })
                    }
                    let todos = habits.filter { habit in
                        !completed.contains(where: { $0.id == habit.id })
                    }
                    self.todos = todos
                    self.completed = todayRecords.map { $0.habit }
                    self.allRecords = allRecords
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
