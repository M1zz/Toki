//
//  AddMessageView.swift
//  Toki
//
//  Created by POS on 7/7/25.
//

import Foundation
import SwiftData
import SwiftUI

struct AddMessageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var messages: [Message]
    
    var body: some View {
        Text("Hello World!")
    }
}
