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
    var isPreset: Bool  // 기본 문구인지 아닌지 확인

    init(text: String, isPreset: Bool = false) {
        self.id = UUID()
        self.text = text
        self.isPreset = isPreset
    }

    static func insertPreset(context: ModelContext) async {
        do {
            let descriptor = FetchDescriptor<Message>()
            let existing = try context.fetch(descriptor)

            if existing.isEmpty {
                let presets = [ // 나중에 csv로 빼면 좋을텐데
                    "시간이 다 끝나갑니다! 빨리빨리!",
                    "타이머가*nn*분 남았습니다. 마무리 준비하세요!"
                ]

                for text in presets {
                    context.insert(Message(text: text, isPreset: true))
                }

                try context.save()
            }
        } catch {
            print("error - insert preset message: \(error)")
        }
    }
}
