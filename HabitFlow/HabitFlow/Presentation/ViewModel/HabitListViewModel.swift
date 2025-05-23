//
//  HabitListViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation
import Combine

final class HabitListViewModel: ObservableObject {
    // MARK: - Input
    @Published var habits: [HabitModel] = []
    
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let useCase: HabitUseCase
    private let notificationUseCase: HabitNotificationUseCase
    
    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        useCase: HabitUseCase,
        notificationUseCase: HabitNotificationUseCase
    ) {
        self.useCase = useCase
        self.notificationUseCase = notificationUseCase
        
        fetchHabits()
    }
    
    // MARK: - Public Methods
    func fetchHabits() {
        useCase.fetchHabits()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] habits in
                self?.habits = habits
            }
            .store(in: &cancellables)
    }
    
    func addHabit(_ habit: HabitModel) {
        useCase.addHabit(habit)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchHabits()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func addHabitWithNotification(_ habit: HabitModel, notify: Bool, notifyTime: Date) {
        useCase.addHabit(habit)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard notify else { return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher() }
                return self?.notificationUseCase.addNotification(habitId: habit.id, time: notifyTime)
                    .flatMap { [weak self] _ in
                        self?.notificationUseCase.scheduleNotification(for: habit.id) ?? Empty().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchHabits()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: {}
            .store(in: &cancellables)
    }
    
    func deleteHabit(id: UUID) {
        useCase.deleteHabit(id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchHabits()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func updateHabit(_ habit: HabitModel) {
        useCase.updateHabit(habit)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchHabits()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func updateHabitWithNotification(_ habit: HabitModel, notify: Bool, notifyTime: Date) {
        useCase.updateHabit(habit)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard notify else { return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher() }
                return self?.notificationUseCase.updateNotification(habitId: habit.id, newTime: notifyTime)
                    .flatMap { [weak self] _ in
                        self?.notificationUseCase.scheduleNotification(for: habit.id) ?? Empty().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchHabits()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: {}
            .store(in: &cancellables)
    }
    
    var groupedHabitsByRoutine: [RoutineType: [HabitModel]] {
        Dictionary(grouping: habits, by: { $0.routineType })
    }
}
