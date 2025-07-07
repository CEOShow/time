//
//  timeApp.swift
//  time Watch App
//
//  Created by Show on 2024/9/28.
//

import SwiftUI

@main
struct timeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 應用程式啟動時請求通知權限
                    NotificationManager.shared.requestNotificationPermission()
                }
        }
    }
}
