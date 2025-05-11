//
//  HabitNotificationViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/10/25.
//

import Foundation
import Combine

final class HabitNotificationViewModel: ObservableObject {
    // MARK: - Input
    @Published var notifications: [HabitNotificationModel] = []
    
    @Published var isNotificationOn: Bool = false
    @Published var notificationTime: Date = Date()
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let notificationUseCase: HabitNotificationUseCase
    private var cancellables = Set<AnyCancellable>()
    private var habitId: UUID?
    
    // MARK: - Init
    init(useCase: HabitNotificationUseCase) {
        self.notificationUseCase = useCase
    }
    
    // MARK: - Actions
    func setHabitId(_ id: UUID) {
        self.habitId = id
        fetchNotification()
    }

    private func fetchNotification() {
        guard let id = habitId else { return }
        
        notificationUseCase.fetchNotification(habitId: id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { entity in
                if let entity = entity {
                    self.isNotificationOn = true
                    self.notificationTime = entity.time ?? Date()
                } else {
                    self.isNotificationOn = false
                }
            }
            .store(in: &cancellables)
    }

    func addNotification(habitId: UUID, time: Date) {
        notificationUseCase.addNotification(habitId: habitId, time: time)
            .flatMap { [weak self] _ in
                self?.notificationUseCase.scheduleNotification(for: habitId) ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: {
                self.isNotificationOn = true
            }
            .store(in: &cancellables)
    }

    func deleteNotification(habitId: UUID) {
        notificationUseCase.deleteNotification(habitId: habitId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: {
                self.isNotificationOn = false
            }
            .store(in: &cancellables)
    }

    func updateNotificationTime(_ newTime: Date) {
        self.notificationTime = newTime
        guard let id = habitId else { return }

        notificationUseCase.updateNotification(habitId: id, newTime: newTime)
            .flatMap { [weak self] _ in
                self?.notificationUseCase.scheduleNotification(for: id) ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: {}
            .store(in: &cancellables)
    }
}
