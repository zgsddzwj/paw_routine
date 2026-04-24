//
//  PawRoutineApp.swift
//  PawRoutine
//
//  Created by Adward on 2026/4/24.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct PawRoutineApp: App {
    @StateObject private var petStore = PetStore()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pet.self,
            Activity.self,
            MedicalRecord.self,
            WeightRecord.self,
            Document.self,
            AppSettings.self
        ])
        // 显式指定本地存储 URL，便于 schema 变更时清理旧数据
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeURL = appSupportURL.appendingPathComponent("PawRoutine.sqlite")
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            allowsSave: true,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schema 变更导致加载失败时，删除旧存储并重建（开发阶段常见处理）
            print("Failed to load ModelContainer: \(error)")
            print("Attempting to delete old store and recreate...")
            
            let fileManager = FileManager.default
            let urlsToDelete = [
                storeURL,
                storeURL.appendingPathExtension("-shm"),
                storeURL.appendingPathExtension("-wal")
            ]
            for url in urlsToDelete {
                try? fileManager.removeItem(at: url)
            }
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after clearing old store: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(petStore)
        }
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}
