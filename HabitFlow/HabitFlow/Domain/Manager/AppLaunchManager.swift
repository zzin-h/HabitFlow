//
//  AppLaunchManager.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/11/25.
//

import Foundation

final class AppLaunchManager {
    static let shared = AppLaunchManager()
    
    private let notificationUseCase = HabitNotificationUseCaseImpl(
        repository: HabitNotificationRepository()
    )
    
    private init() { }
    
    func initializeApp() {
        checkFirstLaunch()
    }
    
    private func checkFirstLaunch() {
        let hasLaunchedBeforeKey = "hasLaunchedBefore"
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: hasLaunchedBeforeKey) {
            notificationUseCase.requestNotificationAuthorization()
            userDefaults.set(true, forKey: hasLaunchedBeforeKey)
        } else {
            notificationUseCase.updateAllIntervalNotifications()
        }
    }
}
