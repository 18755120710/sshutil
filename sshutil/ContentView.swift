//
//  ContentView.swift
//  sshutil
//
//  Created by 可梵 on 2026/4/14.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [SSHSession]
    
    @State private var selectedSession: SSHSession?
    @State private var showingAddSheet = false

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSession) {
                ForEach(sessions) { session in
                    NavigationLink(value: session) {
                        VStack(alignment: .leading) {
                            Text(session.name)
                                .font(.headline)
                            Text("\(session.username)@\(session.host)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationTitle("SSH 主机")
            .toolbar {
                ToolbarItem {
                    Button(action: { showingAddSheet = true }) {
                        Label("Add Server", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let session = selectedSession {
                SessionDetailView(session: session)
            } else {
                Text("请从左侧选择一个服务器")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddServerFormView()
        }
    }

    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sessions[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SSHSession.self, inMemory: true)
}
