//
//  tokiApp.swift
//  toki
//
//  Created by POS on 7/7/25.
//

import SwiftUI
import SwiftData

@main
struct tokiApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Message.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                                    requestNotice()
                                }

        }
        .modelContainer(sharedModelContainer)
    }
}
