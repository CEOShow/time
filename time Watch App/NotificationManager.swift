//
//  NotificationManager.swift
//  time Watch App
//
//  Created by Show on 2024/12/21.
//

import UserNotifications
import Foundation

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
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
        content.body = "回到 App 開始計時休息吧！"
        content.sound = UNNotificationSound.default
        content.userInfo = [
            "notificationType": "focusEnd",
            "scheduledTime": Date().timeIntervalSince1970
        ]
        
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
        content.body = "回到 App 報到吧！"
        content.sound = UNNotificationSound.default
        content.userInfo = [
            "notificationType": "breakEnd",
            "scheduledTime": Date().timeIntervalSince1970
        ]
        
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
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // 當通知在前景時顯示
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
    }
    
    // 當用戶點擊通知時觸發
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let notificationType = userInfo["notificationType"] as? String {
            print("收到通知回調：\(notificationType)")
            
            // 發送通知給應用其他部分
            NotificationCenter.default.post(
                name: Notification.Name("TimerNotificationReceived"),
                object: nil,
                userInfo: ["type": notificationType]
            )
        }
        
        completionHandler()
    }
}
