//
//  AddMessageView.swift
//  Toki
//
//  Created by POS on 7/7/25.
//

import SwiftData
import SwiftUI

struct AddMessageView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var messageText: String = ""

    var body: some View {
        Section(header: Text("문구 입력")) {
            TextField("예: '고마 여기까지인기라'", text: $messageText)
                .autocorrectionDisabled()
        }

        Section {
            Button("Add") {
                addMessage()
            }
            .disabled(
                messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            )
        }
    }

    private func addMessage() {
        let trimmedText = messageText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedText.isEmpty else { return }

        let tmp = Message(text: trimmedText, isPreset: false)
        modelContext.insert(tmp)
        
        ///Add하고 모델컨테이너에는 반영이 되는데 리스트에 fetch가 안돼서 view연결하면서 fetch구현해보면될거같음
        ///debugging section
        do {
            let allMessages = try modelContext.fetch(FetchDescriptor<Message>())
            print("Messages List:")
            for msg in allMessages {
                print("\(msg.text) | isPreset: \(msg.isPreset)")
            }
        } catch {
            print("message fetch failed: \(error)")
        }

        dismiss()
    }
}
