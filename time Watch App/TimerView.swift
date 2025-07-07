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
    
    @State private var remainingTime: Int = 0
    @State private var timer: Timer?
    @State private var currentItemIndex: Int = 0
    @State private var isBreakTime = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) private var scenePhase
    
    // 使用狀態管理器
    private let stateManager = TimerStateManager.shared
    private let notificationManager = NotificationManager.shared
    
    init(selectedItems: [String], minutes: Int) {
        self.selectedItems = selectedItems
        self.minutes = minutes
        
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
            initializeTimer()
        }
        .onDisappear {
            stopTimerOnly()
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    // 初始化計時器
    private func initializeTimer() {
        if stateManager.isTimerRunning {
            // 如果已經有計時會話在進行，恢復狀態
            print("恢復計時會話")
            restoreTimerState()
        } else {
            // 開始新的計時會話
            print("開始新的計時會話")
            stateManager.startTimerSession(
                selectedItems: selectedItems,
                focusMinutes: minutes,
                breakMinutes: breakMinutes
            )
            updateLocalState()
            scheduleNotification()
        }
        
        startTimer()
    }
    
    // 恢復計時器狀態
    private func restoreTimerState() {
        // 檢查階段是否已完成
        let phaseStatus = stateManager.checkPhaseCompletion()
        
        switch phaseStatus {
        case .continuing:
            // 階段還在繼續
            updateLocalState()
            scheduleNotification()
            
        case .breakStarted:
            // 應該開始休息了
            updateLocalState()
            scheduleNotification()
            print("檢測到應該開始休息")
            
        case .focusStarted:
            // 應該開始下一個專注項目了
            updateLocalState()
            scheduleNotification()
            print("檢測到應該開始下一個專注項目")
            
        case .allCompleted:
            // 所有項目已完成
            print("所有項目已完成")
            presentationMode.wrappedValue.dismiss()
            return
        }
    }
    
    // 更新本地狀態
    private func updateLocalState() {
        isBreakTime = stateManager.isBreakTime
        currentItemIndex = stateManager.currentItemIndex
        remainingTime = stateManager.getCurrentRemainingTime()
        
        print("更新本地狀態：\(isBreakTime ? "休息" : "專注")，項目 \(currentItemIndex)，剩餘 \(remainingTime) 秒")
    }
    
    // 安排通知
    private func scheduleNotification() {
        notificationManager.cancelAllNotifications()
        
        if remainingTime > 0 {
            if isBreakTime {
                notificationManager.scheduleBreakEndNotification(after: TimeInterval(remainingTime))
            } else {
                notificationManager.scheduleFocusEndNotification(after: TimeInterval(remainingTime))
            }
        }
    }
    
    // 處理場景狀態變化
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("App 回到前景")
            if stateManager.isTimerRunning {
                restoreTimerState()
                if timer == nil {
                    startTimer()
                }
            }
            
        case .inactive, .background:
            print("App 進入背景")
            stopTimerOnly()
            
        @unknown default:
            break
        }
    }
    
    // 開始計時器
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                handlePhaseCompletion()
            }
        }
    }
    
    // 處理階段完成
    private func handlePhaseCompletion() {
        let phaseStatus = stateManager.checkPhaseCompletion()
        
        switch phaseStatus {
        case .continuing:
            break
            
        case .breakStarted:
            updateLocalState()
            scheduleNotification()
            print("開始休息時間")
            
        case .focusStarted:
            updateLocalState()
            scheduleNotification()
            print("開始下一個專注項目")
            
        case .allCompleted:
            print("所有項目已完成")
            stopTimer()
        }
    }
    
    // 只停止計時器
    private func stopTimerOnly() {
        timer?.invalidate()
        timer = nil
    }
    
    // 停止計時器並退出
    private func stopTimer() {
        stopTimerOnly()
        stateManager.stopTimer()
        notificationManager.cancelAllNotifications()
        presentationMode.wrappedValue.dismiss()
    }
    
    // 格式化時間顯示
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
