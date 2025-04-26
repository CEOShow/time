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
    @AppStorage("breakMinutes") private var breakMinutes = 5
    @State private var remainingTime: Int
    @State private var timer: Timer?
    @State private var currentItemIndex: Int
    @State private var isBreakTime = false
    @Environment(\.presentationMode) var presentationMode
    
    init(selectedItems: [String], minutes: Int) {
        self.selectedItems = selectedItems
        self.minutes = minutes
        self._remainingTime = State(initialValue: minutes * 60)
        self._currentItemIndex = State(initialValue: selectedItems.isEmpty ? -1 : 0)
        
        // 印出接收到的項目，用於調試
        print("TimerView初始化，收到\(selectedItems.count)個項目：\(selectedItems)")
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 顯示當前狀態（專注或休息）
            Text(isBreakTime ? "休息時間" : "專注時間")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 10)
            
            // 顯示剩餘時間
            Text("\(formatTime(remainingTime))")
                .font(.system(size: 40, weight: .bold))
                .padding(.bottom, 5)
            
            // 專注時間時顯示當前項目，休息時間則顯示提示訊息
            if !isBreakTime {
                if !selectedItems.isEmpty && currentItemIndex >= 0 && currentItemIndex < selectedItems.count {
                    Group {
                        if selectedItems.count > 1 {
                            Text("\(currentItemIndex + 1). \(selectedItems[currentItemIndex])")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.blue)
                        } else {
                            Text(selectedItems[currentItemIndex])
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("沒有可專注的項目")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .padding()
                }
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
            print("TimerView出現，項目數量：\(selectedItems.count)")
            if !selectedItems.isEmpty {
                startTimer()
            }
        }
    }
    
    // 開始計時器
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                if isBreakTime {
                    nextItem()
                } else {
                    startBreak()
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
        if !selectedItems.isEmpty && currentItemIndex < selectedItems.count - 1 {
            currentItemIndex += 1
            remainingTime = minutes * 60
            print("進入下一項目：\(selectedItems[currentItemIndex])")
        } else {
            print("所有項目已完成")
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
