//
//  MessageListView.swift
//  Toki
//
//  Created by POS on 7/7/25.
//  알림 메세지를 조회하고 편집할 수 있는 뷰

import SwiftData
import SwiftUI

struct MessageListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var messages: [Message]
    @State private var selectedID: UUID?
    @State private var showAddMessageView = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(messages) { message in
                    HStack {
                        Text(message.text)

                        Spacer()

                        Button {
                            selectedID = message.id
                        } label: {
                            Image(systemName: selectedID == message.id? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete(perform: delMes)

                Button {
                    showAddMessageView = true
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())

                NavigationLink(
                    destination: AddMessageView(),
                    isActive: $showAddMessageView
                ) {
                    EmptyView()
                }
                .hidden()

            }
            /// 가장 위에 있는 메세지가 기본값
            .onAppear {
                if selectedID == nil, let first = messages.first {
                    selectedID = first.id
                }
            }
        }
        .navigationTitle("알림 문구 목록")
    }

    /// 문구 삭제
    private func delMes(at offsets: IndexSet) {
        for index in offsets {
            let message = messages[index]
            if message.isPreset {
                Text("나중에 튤팁으로 띄워보기 - 프리셋 문구를 삭제할 수 없습니다!")
            } else {
                modelContext.delete(message)
            }
        }
    }
}
