//
//  TimerTemplateView.swift
//  Toki
//
//  Created by POS on 8/26/25.
//

import Foundation
import SwiftData
import SwiftUI

struct TimerTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query(sort: [SortDescriptor(\Timer.createdAt, order: .reverse)])

    private var templates: [Timer]

    let onSelect: (Timer) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if templates.isEmpty {
                    ContentUnavailableView(
                        "저장된 템플릿이 없습니다",
                        systemImage: "exclamationmark.triangle",
                        description: Text("컨텐트불가능뷰이거완전신기하당")
                    )
                    .padding(.top, 40)
                } else {
                    List {
                        ForEach(templates) { t in
                            Button {
                                onSelect(t)
                                dismiss()
                            } label: {
                                let pre = t.prealertOffsetsSec
                                    .sorted()
                                    .map { "\($0/60)분" }
                                    .joined(separator: ", ")
                                Text("메인 \(t.mainSeconds/60)분, 예비: \(pre)")
                            }
                            .swipeActions(
                                edge: .trailing,
                                allowsFullSwipe: true
                            ) {
                                Button(role: .destructive) {
                                    delete(t)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
    }

    private func delete(_ t: Timer) {
        withAnimation {
            context.delete(t)
            try? context.save()
        }
    }
}
