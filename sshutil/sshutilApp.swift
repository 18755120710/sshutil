//
//  sshutilApp.swift
//  sshutil
//
//  Created by 可梵 on 2026/4/14.
//

import SwiftUI
import SwiftData

@main
struct sshutilApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SSHSession.self,
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
        }
        .modelContainer(sharedModelContainer)
    }
}
