//
//  HabitNotificationUseCaseImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/10/25.
//

import Foundation
import Combine
import UserNotifications
import CoreData

final class HabitNotificationUseCaseImpl: HabitNotificationUseCase {
    private let repository: HabitNotificationRepository
    private let context: NSManagedObjectContext
    private let center = UNUserNotificationCenter.current()
    
    init(repository: HabitNotificationRepository,
         context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.repository = repository
        self.context = context
    }
    
    func addNotification(habitId: UUID, time: Date) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "usecase.deallocated", code: -1)))
                return
            }
            
            do {
                try self.repository.addNotification(for: habitId, time: time)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchNotification(habitId: UUID) -> AnyPublisher<HabitNotificationEntity?, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "usecase.deallocated", code: -1)))
                return
            }
            
            do {
                let notification = try self.repository.fetchNotification(for: habitId)
                promise(.success(notification))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateNotification(habitId: UUID, newTime: Date) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "usecase.deallocated", code: -1)))
                return
            }
            
            do {
                try self.repository.updateNotification(for: habitId, newTime: newTime)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteNotification(habitId: UUID) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "usecase.deallocated", code: -1)))
                return
            }
            
            do {
                try self.repository.deleteNotification(for: habitId)
                removeAllNotifications(for: habitId, completion: {})
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeAllNotifications(for habitId: UUID, completion: @escaping () -> Void) {
        let prefix = habitId.uuidString
        center.getPendingNotificationRequests { requests in
            let matchingIdentifiers = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(prefix) }
            self.center.removePendingNotificationRequests(withIdentifiers: matchingIdentifiers)
            
            print("🗑 삭제된 알림 IDs: \(matchingIdentifiers)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion()
            }
        }
    }
    
    func requestNotificationAuthorization() {
        center.requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("❌ 알림 권한 요청 실패: \(error.localizedDescription)")
            } else {
                print("✅ 알림 권한 granted: \(granted)")
            }
        }
        
        center.getPendingNotificationRequests { requests in
            print("🔔 현재 등록된 알림 개수: \(requests.count)")
            for req in requests {
                print("📝 알림 ID: \(req.identifier)")
            }
        }
    }
    
    func scheduleNotification(for habitId: UUID) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "usecase.deallocated", code: -1)))
                return
            }
            
            let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", habitId as CVarArg)
            
            do {
                guard let habit = try self.context.fetch(request).first,
                      let time = habit.notifications?.time,
                      let title = habit.title else {
                    throw NSError(domain: "Habit not found or invalid", code: 404)
                }
                
                removeAllNotifications(for: habitId) {
                    let routineType = habit.routineType
                    switch routineType {
                    case "daily":
                        self.scheduleDaily(habitId: habitId, title: title, time: time)
                        
                    case "weekly":
                        if let weekdays = habit.selectedDays {
                            self.scheduleWeekly(habitId: habitId, title: title, time: time, weekdays: weekdays as? [String] ?? [])
                        }
                        
                    case "interval":
                        self.scheduleInterval(habitId: habitId, title: title, time: time, startDate: habit.createdAt, intervalDays: Int(habit.intervalDays))
                        
                    case .none:
                        return
                        
                    case .some(_):
                        return
                    }
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateAllIntervalNotifications() {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "routineType == %@", "interval")
        
        do {
            let intervalHabits = try context.fetch(request)
            
            for habit in intervalHabits {
                guard let habitId = habit.id,
                      let title = habit.title,
                      let time = habit.notifications?.time else { continue }
                
                let identifiers = (0..<21).map { "\(habitId.uuidString)_interval_\($0)" }
                center.removePendingNotificationRequests(withIdentifiers: identifiers)
                
                scheduleIntervalFromToday(habitId: habitId, title: title, time: time, intervalDays: Int(habit.intervalDays))
            }
            
        } catch {
            print("⛔️ Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func scheduleDaily(habitId: UUID, title: String, time: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = String(localized: "habit_reminder_today")
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: habitId.uuidString, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("⛔️ Notification Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleWeekly(habitId: UUID, title: String, time: Date, weekdays: [String]) {
        let weekdayEnums = weekdays.compactMap { Weekdays(rawValue: $0) }
        
        for weekday in weekdayEnums {
            var components = Calendar.current.dateComponents([.hour, .minute], from: time)
            components.weekday = weekday.index
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let content = UNMutableNotificationContent()
            let localizedWeekdays = weekdayEnums.map { $0.shortTitle }.joined(separator: "·")
            
            content.title = title
            content.body = String(format: NSLocalizedString("habit_reminder_weekday_cycle", comment: ""), localizedWeekdays)
            content.sound = .default
            
            let id = "\(habitId.uuidString)_\(weekday)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("⛔️ Notification Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func scheduleInterval(habitId: UUID, title: String, time: Date, startDate: Date?, intervalDays: Int) {
        guard let startDate = startDate else { return }
        
        let calendar = Calendar.current
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = String(format: NSLocalizedString("habit_reminder_day_cycle", comment: ""), intervalDays)
        content.sound = .default
        
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        for i in 0..<21 {
            if let date = calendar.date(byAdding: .day, value: intervalDays * i, to: startDate) {
                var triggerDate = calendar.dateComponents([.year, .month, .day], from: date)
                triggerDate.hour = timeComponents.hour
                triggerDate.minute = timeComponents.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "\(habitId.uuidString)_interval_\(i)",
                    content: content,
                    trigger: trigger
                )
                
                center.add(request) { error in
                    if let error = error {
                        print("⛔️ Notification Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func scheduleIntervalFromToday(habitId: UUID, title: String, time: Date, intervalDays: Int) {
        let calendar = Calendar.current
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = String(format: NSLocalizedString("habit_reminder_day_cycle", comment: ""), intervalDays)
        content.sound = .default
        
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        let today = Date()
        
        for i in 0..<21 {
            if let date = calendar.date(byAdding: .day, value: intervalDays * i, to: today) {
                var triggerDate = calendar.dateComponents([.year, .month, .day], from: date)
                triggerDate.hour = timeComponents.hour
                triggerDate.minute = timeComponents.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "\(habitId.uuidString)_interval_\(i)",
                    content: content,
                    trigger: trigger
                )
                
                center.add(request) { error in
                    if let error = error {
                        print("⛔️ Notification Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
