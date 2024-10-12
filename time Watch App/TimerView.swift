//
//  TimerView.swift
//  time Watch App
//
//  Created by Show on 2024/10/5.
//

import SwiftUI

struct TimerView: View {
    let selectedItem: String
    let minutes: Int

    var body: some View {
        VStack {
            Text("計時中: \(selectedItem)")
                .font(.largeTitle)
                .padding()

            Text("\(minutes) 分鐘")
                .font(.title)

            Button(action: {
                // 停止計時邏輯
            }) {
                Text("停止")
            }
            .buttonStyle(TimerButtonStyle())
        }
    }
}

struct TimerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 80, height: 35)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .cornerRadius(17.5)
    }
}

struct FocusItem: Identifiable {
    let id = UUID()
    let name: String
}
