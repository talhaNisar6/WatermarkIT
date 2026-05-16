//
//  WatermarkITApp.swift
//  WatermarkIT
//

import SwiftUI
import SwiftData

@main
struct WatermarkITApp: App {

    // MARK: - SwiftData ModelContainer
    // ModelContainer is like CoreData's persistent store coordinator
    // It manages reading/writing WatermarkTemplate to disk
    // We register WatermarkTemplate here — SwiftData finds all @Model classes inside
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WatermarkTemplate.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false     // false = persists to disk
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()                      // HomeView is our root screen
        }
        .modelContainer(sharedModelContainer)
        // .modelContainer injects the container into the environment
        // Any view can access it via @Environment(\.modelContext)
    }
}
