//
//  SettingsView.swift
//  time Watch App
//
//  Created by Show on 2024/11/2.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: FocusItemSettingsView()) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.blue)
                        Text("專注項目")
                    }
                }
                
                NavigationLink(destination: TimeSettingsView()) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text("預設時間")
                    }
                }
            }
            .navigationTitle("設定")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 這是預留的視圖，之後再實作細節
struct FocusItemSettingsView: View {
    var body: some View {
        Text("專注項目設定")
            .navigationTitle("專注項目")
    }
}

// 這是預留的視圖，之後再實作細節
struct TimeSettingsView: View {
    var body: some View {
        Text("時間設定")
            .navigationTitle("預設時間")
    }
}

#Preview {
    SettingsView()
}
