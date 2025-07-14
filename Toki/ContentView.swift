//
//  ContentView.swift
//  toki
//
//  Created by POS on 7/7/25.
//

import SwiftUI
import SwiftData
import SwiftUI
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        TimerView()
            .onAppear {
                // 알림 권한 요청
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("알림 권한 요청 오류: \(error)")
                    }
                }
            }
//        MessageListView()
//            .task {
//                await Message.insertPreset(context: modelContext)
//            }
//        RingDebugView()
        
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
