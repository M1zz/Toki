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

    var body: some View {
        NavigationStack {
            VStack{
                ForEach(messages) { message in
                    Text(message.text)
                }
                .onDelete(perform: delMes)
                
                NavigationLink(destination: AddMessageView()) {
                    HStack {
                        Text("새 문구 추가하기")
                    }
                }
            }
        }
        .navigationTitle("알림 문구 목록")
    }

    /// 문구 삭제
    private func delMes(at offsets: IndexSet) {
        for index in offsets {
            let message = messages[index]
            if !message.isPreSet {
                modelContext.delete(message)
            }
        }
    }
}
