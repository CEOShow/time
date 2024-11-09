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

#Preview {
    SettingsView()
}
