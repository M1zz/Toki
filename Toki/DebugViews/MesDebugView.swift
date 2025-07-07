//
//  MesDebugView.swift
//  Toki
//
//  Created by POS on 7/7/25.
//

import SwiftData
import SwiftUI

struct MesDebugView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MessageListView()
            .task {
                await Message.insertPreset(context: modelContext)
            }
    }
}

