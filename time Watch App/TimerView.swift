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
    @AppStorage("breakMinutes") private var breakMinutes = 5 // 預設休息時間
    @State private var remainingTime: Int
    @State private var timer: Timer?
    @State private var currentItemIndex = 0
    @State private var isBreakTime = false // 是否為休息時間
    @Environment(\.presentationMode) var presentationMode
    
    init(selectedItems: [String], minutes: Int) {
        self.selectedItems = selectedItems
        self.minutes = minutes
        self._remainingTime = State(initialValue: minutes * 60)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            // 顯示當前狀態（專注或休息）
            Text(isBreakTime ? "休息時間" : "專注時間")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 10)
            
            // 顯示剩餘時間
            Text("\(formatTime(remainingTime))")
                .font(.system(size: 40, weight: .bold))
                .padding(.bottom, 5)
            
            // 專注時間時顯示項目列表，休息時間則顯示提示訊息
            if !isBreakTime {
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
            } else {
                Text("休息一下 放鬆心情～")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
                    .padding()
            }
            
            Spacer()
            
            // 停止按鈕
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
    
    // 開始計時器
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                if isBreakTime {
                    nextItem() // 休息結束，進入下一個項目
                } else {
                    startBreak() // 專注結束，開始休息
                }
            }
        }
    }
    
    // 開始休息時間
    private func startBreak() {
        isBreakTime = true
        remainingTime = breakMinutes * 60
    }
    
    // 進入下一個專注項目
    private func nextItem() {
        isBreakTime = false
        if currentItemIndex < selectedItems.count - 1 {
            currentItemIndex += 1
            remainingTime = minutes * 60
        } else {
            stopTimer()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // 停止計時器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 格式化時間顯示
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
