//
//  TimerUnifiedView.swift
//  Toki
//
//  Created by xa on 8/28/25.
//

import Foundation
import SwiftUI

struct TimerUnifiedView: View {
    @Environment(\.modelContext) private var context

    @StateObject private var screenVM = TimerScreenViewModel()
    @StateObject private var toast = ToastManager()

    @State private var showHistory = false

    var body: some View {
        NavigationStack {
            Group {
                switch screenVM.timerVM.state {
                case .idle:
                    TimerSetupView()
                        .environmentObject(screenVM)

                case .running, .paused:
                    TimerRunningView()
                        .environmentObject(screenVM)

                default:
                    TimerRunningView()
                        .environmentObject(screenVM)
                }
            }
            .padding()
            .toolbar {
                // timer template
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
                // notice setting
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NoticeSettingView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            TimerTemplateView { selected in
                screenVM.apply(template: selected)
            }
            .presentationDetents(Set<PresentationDetent>([.medium, .large]))
            .presentationDragIndicator(Visibility.visible)
        }
        .toast(toast)
        .onAppear {
            screenVM.attachContext(context)
            screenVM.timerVM.showToast = { toast.show(Toast($0)) }
            screenVM.showToast = { toast.show(Toast($0)) }
            screenVM.initialConfiguration()
        }
    }
}
