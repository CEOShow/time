//
//  TimerStateManager.swift
//  time Watch App
//
//  Created by Show on 2025/6/28.
//

import Foundation

class TimerStateManager: ObservableObject {
    static let shared = TimerStateManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let isTimerRunning = "isTimerRunning"
        static let isBreakTime = "isBreakTime"
        static let currentItemIndex = "currentItemIndex"
        static let phaseStartTime = "phaseStartTime"
        static let phaseDuration = "phaseDuration"
        static let selectedItems = "selectedItems"
        static let focusMinutes = "focusMinutes"
        static let breakMinutes = "breakMinutes"
    }
    
    // MARK: - Properties
    var isTimerRunning: Bool {
        get { userDefaults.bool(forKey: Keys.isTimerRunning) }
        set { userDefaults.set(newValue, forKey: Keys.isTimerRunning) }
    }
    
    var isBreakTime: Bool {
        get { userDefaults.bool(forKey: Keys.isBreakTime) }
        set { userDefaults.set(newValue, forKey: Keys.isBreakTime) }
    }
    
    var currentItemIndex: Int {
        get { userDefaults.integer(forKey: Keys.currentItemIndex) }
        set { userDefaults.set(newValue, forKey: Keys.currentItemIndex) }
    }
    
    var phaseStartTime: Date? {
        get { userDefaults.object(forKey: Keys.phaseStartTime) as? Date }
        set { userDefaults.set(newValue, forKey: Keys.phaseStartTime) }
    }
    
    var phaseDuration: Int {
        get { userDefaults.integer(forKey: Keys.phaseDuration) }
        set { userDefaults.set(newValue, forKey: Keys.phaseDuration) }
    }
    
    var selectedItems: [String] {
        get { userDefaults.stringArray(forKey: Keys.selectedItems) ?? [] }
        set { userDefaults.set(newValue, forKey: Keys.selectedItems) }
    }
    
    var focusMinutes: Int {
        get { userDefaults.integer(forKey: Keys.focusMinutes) }
        set { userDefaults.set(newValue, forKey: Keys.focusMinutes) }
    }
    
    var breakMinutes: Int {
        get { userDefaults.integer(forKey: Keys.breakMinutes) }
        set { userDefaults.set(newValue, forKey: Keys.breakMinutes) }
    }
    
    // MARK: - Methods
    
    // 開始計時會話
    func startTimerSession(selectedItems: [String], focusMinutes: Int, breakMinutes: Int) {
        self.isTimerRunning = true
        self.isBreakTime = false
        self.currentItemIndex = 0
        self.phaseStartTime = Date()
        self.phaseDuration = focusMinutes * 60
        self.selectedItems = selectedItems
        self.focusMinutes = focusMinutes
        self.breakMinutes = breakMinutes
        
        print("計時會話已開始：專注 \(focusMinutes) 分鐘")
    }
    
    // 開始休息
    func startBreak() {
        self.isBreakTime = true
        self.phaseStartTime = Date()
        self.phaseDuration = breakMinutes * 60
        
        print("休息時間已開始：\(breakMinutes) 分鐘")
    }
    
    // 進入下一個項目
    func nextItem() -> Bool {
        if currentItemIndex < selectedItems.count - 1 {
            self.isBreakTime = false
            self.currentItemIndex += 1
            self.phaseStartTime = Date()
            self.phaseDuration = focusMinutes * 60
            
            print("進入下一個項目：\(selectedItems[currentItemIndex])")
            return true
        } else {
            // 所有項目完成
            stopTimer()
            return false
        }
    }
    
    // 停止計時器
    func stopTimer() {
        self.isTimerRunning = false
        self.isBreakTime = false
        self.currentItemIndex = 0
        self.phaseStartTime = nil
        self.phaseDuration = 0
        self.selectedItems = []
        
        print("計時器已停止")
    }
    
    // 計算當前剩餘時間
    func getCurrentRemainingTime() -> Int {
        guard let startTime = phaseStartTime else { return 0 }
        
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let remaining = max(0, phaseDuration - elapsed)
        
        return remaining
    }
    
    // 檢查當前階段是否已結束
    func checkPhaseCompletion() -> PhaseStatus {
        let remainingTime = getCurrentRemainingTime()
        
        if remainingTime <= 0 {
            if isBreakTime {
                // 休息時間結束
                if nextItem() {
                    return .focusStarted
                } else {
                    return .allCompleted
                }
            } else {
                // 專注時間結束
                startBreak()
                return .breakStarted
            }
        } else {
            return .continuing
        }
    }
    
    enum PhaseStatus {
        case continuing
        case breakStarted
        case focusStarted
        case allCompleted
    }
}
