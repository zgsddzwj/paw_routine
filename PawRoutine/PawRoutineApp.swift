//
//  PawRoutineApp.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/22.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct PawRoutineApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pet.self,
            DailyRecord.self,
            WeightRecord.self,
            MedicalRecord.self,
            Document.self,
            AppSettings.self,
        ])
        
        // CloudKit 配置 - 使用用户私有数据库
        let cloudKitModelConfiguration = ModelConfiguration(
            "PawRoutineCloud",
            schema: schema,
            allowsSave: true
        )
        
        let localModelConfiguration = ModelConfiguration(
            "PawRoutineLocal",
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [cloudKitModelConfiguration, localModelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    requestNotificationPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Notification Permission
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                print("Notification permission error: \(error)")
            }
            if granted {
                print("Notification permission granted")
            }
        }
    }
}
