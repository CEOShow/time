//
//  NotificationManager.swift
//  time Watch App
//
//  Created by Show on 2024/12/21.
//

import UserNotifications
import Foundation

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 請求通知權限
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知權限已獲得授權")
            } else {
                print("通知權限被拒絕")
            }
            
            if let error = error {
                print("請求通知權限時發生錯誤：\(error.localizedDescription)")
            }
        }
    }
    
    // 安排專注時間結束通知
    func scheduleFocusEndNotification(after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "專注時間到囉！"
        content.body = "先休息一下吧～"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "focusEnd",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("安排專注結束通知時發生錯誤：\(error.localizedDescription)")
            } else {
                print("專注結束通知已安排，\(seconds)秒後觸發")
            }
        }
    }
    
    // 安排休息時間結束通知
    func scheduleBreakEndNotification(after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "休息時間到囉！"
        content.body = "趕快去做下一件事情吧～"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "breakEnd",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("安排休息結束通知時發生錯誤：\(error.localizedDescription)")
            } else {
                print("休息結束通知已安排，\(seconds)秒後觸發")
            }
        }
    }
    
    // 取消所有通知
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("所有通知已取消")
    }
    
    // 取消特定通知
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("已取消通知：\(identifier)")
    }
}
