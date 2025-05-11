//
//  HabitNotificationUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/10/25.
//

import Foundation
import Combine

protocol HabitNotificationUseCase {
    func addNotification(habitId: UUID, time: Date) -> AnyPublisher<Void, Error>
    func fetchNotification(habitId: UUID) -> AnyPublisher<HabitNotificationEntity?, Error>
    func updateNotification(habitId: UUID, newTime: Date) -> AnyPublisher<Void, Error>
    func deleteNotification(habitId: UUID) -> AnyPublisher<Void, Error>
    func scheduleNotification(for habitId: UUID) -> AnyPublisher<Void, Error>
    func requestNotificationAuthorization()
    func updateAllIntervalNotifications()
}
