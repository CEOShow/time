//
//  TimeSettingsView.swift
//  time Watch App
//
//  Created by Show on 2024/11/9.
//

import SwiftUI

struct TimeSettingsView: View {
    @AppStorage("defaultMinutes") private var defaultMinutes = 25
    
    var body: some View {
        VStack(spacing: 2) {
            Text("預設專注時間")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 15) {
                Button(action: {
                    if defaultMinutes > 1 {
                        defaultMinutes -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                Text("\(defaultMinutes)")
                    .font(.system(size: 25, weight: .bold))
                    .frame(width: 35)
                
                Button(action: {
                    if defaultMinutes < 60 {
                        defaultMinutes += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            
            Text("此設定將會在下次開啟 App 時生效")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .navigationTitle("預設時間")
        .padding()
    }
}

#Preview {
    NavigationStack {
        TimeSettingsView()
    }
}
