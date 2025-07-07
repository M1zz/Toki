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
        
            .task {
                await Message.insertPreSet(context: modelContext)
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Message.self, inMemory: true)
}
