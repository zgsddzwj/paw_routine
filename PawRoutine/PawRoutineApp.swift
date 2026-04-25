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
        
        // 先尝试 CloudKit；若不可用则回退本地存储
        let cloudConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [cloudConfig])
            #if DEBUG
            print("CloudKit sync enabled")
            #endif
            return container
        } catch {
            #if DEBUG
            print("CloudKit unavailable, using local storage: \(error)")
            #endif
            let localConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            return try! ModelContainer(for: schema, configurations: [localConfig])
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
        // Set notification delegate to allow foreground banners
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Start observing StoreKit transactions
        IAPManager.shared.observeTransactions()
        
        // Sync purchase status on launch
        Task {
            await IAPManager.shared.syncEntitlements()
        }
    }
}
