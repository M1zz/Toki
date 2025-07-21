//
//  ControlButtonView.swift
//  Toki
//
//  Created by POS on 7/20/25.
//

import Foundation
import SwiftUI

struct ControlButtonsView: View {
    @ObservedObject var viewModel: ControlButtonsViewModel

    var body: some View {
        HStack(spacing: 40) {
            let resetType = viewModel.leftside
            Button(action: {
                viewModel.performAction(for: resetType)
            }) {
                VStack(spacing: 4) {
                    Text(resetType.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.isResetEnabled ? resetType.foregroundColor : .gray)
                }
                .frame(width: 90, height: 90)
                .background(
                    Circle()
                        .fill(resetType.backgroundColor.opacity(viewModel.isResetEnabled ? 1.0 : 0.3))
                )
            }
            .disabled(!viewModel.isResetEnabled)

            Spacer()

            if let mainType = viewModel.rightside {
                Button(action: {
                    viewModel.performAction(for: mainType)
                }) {
                    VStack(spacing: 4) {
                        Text(mainType.label)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(mainType.foregroundColor)
                    }
                    .frame(width: 90, height: 90)
                    .background(
                        Circle()
                            .fill(mainType.backgroundColor)
                    )
                }
            }
        }
        .padding(.horizontal, 40)
    }
}

