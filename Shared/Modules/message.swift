//
//  meggage.swift
//  Toki
//
//  Created by POS on 7/7/25.
//  알림 메세지를 다루는 데이터 모델

import Foundation
import SwiftData

@Model
class Message {
    @Attribute(.unique) var id: UUID
    var text: String  // 표시될 문구
    var isPreSet: Bool  // 기본 문구인지 아닌지 확인

    init(text: String, isPreSet: Bool = false) {
        self.id = UUID()
        self.text = text
        self.isPreSet = isPreSet
    }

    static func insertPreSet(context: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<Message>()
            let existing = try context.fetch(descriptor)

            if existing.isEmpty {
                let presets = [ // 나중에 csv로 빼면 좋을텐데
                    "타이머가 종료되었습니다",
                    "타이머가*nn*분 남았습니다. 마무리 준비하세요!"
                ]

                for text in presets {
                    context.insert(Message(text: text, isPreSet: true))
                }

                try context.save()
            }
        } catch {
            print("error - insert preset message: \(error)")
        }
    }
}
