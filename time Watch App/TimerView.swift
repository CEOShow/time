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
    @State private var isPaused = false
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
            
            HStack(spacing: 30) { // 增加按鈕之間的間距
                if !isPaused {
                    Button(action: {
                        pauseTimer()
                    }) {
                        Text("暫停")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40) // 減少按鈕寬度
                            .background(Color.orange)
                            .cornerRadius(20)
                    }
                } else {
                    Button(action: {
                        stopTimer()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("停止")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40) // 減少按鈕寬度
                            .background(Color.red)
                            .cornerRadius(20)
                    }
                    
                    Button(action: {
                        resumeTimer()
                    }) {
                        Text("繼續")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40) // 減少按鈕寬度
                            .background(Color.green)
                            .cornerRadius(20)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20) // 增加左右間距，避免按鈕過於靠近邊界
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
    
    private func pauseTimer() {
        timer?.invalidate()
        isPaused = true
    }
    
    private func resumeTimer() {
        startTimer()
        isPaused = false
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
