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
    @Environment(\.scenePhase) private var scenePhase
    
    // 通知管理器
    private let notificationManager = NotificationManager.shared
    
    // 記錄開始時間，用於計算實際經過的時間
    @State private var startTime: Date = Date()
    @State private var phaseStartTime: Date = Date()
    @State private var totalDuration: Int = 0
    
    init(selectedItems: [String], minutes: Int) {
        self.selectedItems = selectedItems
        self.minutes = minutes
        self._remainingTime = State(initialValue: minutes * 60)
        self._currentItemIndex = State(initialValue: selectedItems.isEmpty ? -1 : 0)
        self._totalDuration = State(initialValue: minutes * 60)
        
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
            
            // 提示文字
            Text("即使回到主畫面，計時仍會繼續進行")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            // 停止按鈕
            Button(action: {
                stopTimer()
                // 取消所有通知
                notificationManager.cancelAllNotifications()
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
                // 安排專注時間結束通知
                notificationManager.scheduleFocusEndNotification(after: TimeInterval(remainingTime))
            }
        }
        .onDisappear {
            // 當 View 消失時取消所有通知
            notificationManager.cancelAllNotifications()
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    // 處理場景狀態變化（前景/背景切換）
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // App 回到前景，重新計算剩餘時間
            updateTimeFromBackground()
            if timer == nil {
                startTimer()
            }
            print("App 回到前景")
            
        case .inactive, .background:
            // App 進入背景，停止計時器但保留通知
            stopTimerOnly()
            print("App 進入背景")
            
        @unknown default:
            break
        }
    }
    
    // 從背景回來時更新時間
    private func updateTimeFromBackground() {
        let now = Date()
        let elapsed = Int(now.timeIntervalSince(phaseStartTime))
        
        if elapsed > 0 {
            remainingTime = max(0, remainingTime - elapsed)
            
            // 檢查是否時間已到
            if remainingTime <= 0 {
                if isBreakTime {
                    nextItem()
                } else {
                    startBreak()
                }
            }
        }
        
        // 更新階段開始時間
        phaseStartTime = now
    }
    
    // 開始計時器
    private func startTimer() {
        phaseStartTime = Date()
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
    
    // 只停止計時器，不取消通知
    private func stopTimerOnly() {
        timer?.invalidate()
        timer = nil
    }
    
    // 開始休息時間
    private func startBreak() {
        isBreakTime = true
        remainingTime = breakMinutes * 60
        phaseStartTime = Date()
        
        // 取消之前的通知並安排休息結束通知
        notificationManager.cancelAllNotifications()
        notificationManager.scheduleBreakEndNotification(after: TimeInterval(remainingTime))
        
        print("開始休息時間，\(breakMinutes)分鐘")
    }
    
    // 進入下一個專注項目
    private func nextItem() {
        isBreakTime = false
        if !selectedItems.isEmpty && currentItemIndex < selectedItems.count - 1 {
            currentItemIndex += 1
            remainingTime = minutes * 60
            phaseStartTime = Date()
            
            // 取消之前的通知並安排新的專注結束通知
            notificationManager.cancelAllNotifications()
            notificationManager.scheduleFocusEndNotification(after: TimeInterval(remainingTime))
            
            print("進入下一項目：\(selectedItems[currentItemIndex])")
        } else {
            print("所有項目已完成")
            stopTimer()
            notificationManager.cancelAllNotifications()
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
