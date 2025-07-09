//
//  ContentView.swift
//  toki
//
//  Created by POS on 7/7/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Text("Hello Toki!")
//        MessageListView()
//            .task {
//                await Message.insertPreset(context: modelContext)
//            }
//        RingDebugView()
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Message.self, inMemory: true)
}
