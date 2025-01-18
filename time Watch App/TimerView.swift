//
//  TimerView.swift
//  time Watch App
//
//  Created by Show on 2024/10/5.
//

import SwiftUI

struct TimerView: View {
    let selectedItems: [String]
    let minutes: Int
    @State private var remainingTime: Int
    @State private var timer: Timer?
    @State private var currentItemIndex = 0
    @Environment(\.presentationMode) var presentationMode
    
    init(selectedItems: [String], minutes: Int) {
        self.selectedItems = selectedItems
        self.minutes = minutes
        self._remainingTime = State(initialValue: minutes * 60)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text("計時中")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 10)
            
            Text("\(formatTime(remainingTime))")
                .font(.system(size: 40, weight: .bold))
                .padding(.bottom, 5)
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(selectedItems.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 5) {
                        Text("\(index + 1).")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(index == currentItemIndex ? .blue : .gray)
                        Text(item)
                            .font(.system(size: 16))
                            .foregroundColor(index == currentItemIndex ? .blue : .primary)
                        if index == currentItemIndex {
                            Image(systemName: "arrow.forward")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                stopTimer()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("停止")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 90, height: 40)
                    .background(Color.red)
                    .cornerRadius(20)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            startTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                nextItem()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func nextItem() {
        if currentItemIndex < selectedItems.count - 1 {
            currentItemIndex += 1
            remainingTime = minutes * 60
        } else {
            stopTimer()
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
