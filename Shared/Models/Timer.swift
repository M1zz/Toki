//
//  Timer.swift
//  Toki
//
//  Created by POS on 8/24/25.
//

import Foundation
import SwiftData

@Model
final class Timer {
    @Attribute(.unique) var id: UUID
    var name: String
    var mainSeconds: Int  // main timer time
    var prealertOffsetsSec: [Int]  // prealert offset time from mainSeconds
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \TimerRecord.template)
    var runs: [TimerRecord] = []

    init(
        id: UUID = UUID(),
        name: String,
        mainSeconds: Int,
        prealertOffsetsSec: [Int],
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.mainSeconds = max(1, mainSeconds)
        self.prealertOffsetsSec = prealertOffsetsSec
        self.createdAt = createdAt
        _ = validateInPlace()
    }

    @discardableResult
    // error case identifier: time is not enough to be prealert
    func validateInPlace() -> Self {
        let filtered =
            prealertOffsetsSec
            .filter { $0 > 0 && $0 < mainSeconds }
        let uniqueSorted = Array(Set(filtered)).sorted()
        self.prealertOffsetsSec = uniqueSorted
        return self
    }
}

extension Timer {
    // prealert time components
    static let presetOffsetsSec: [Int] = [60, 180, 300]
}
