//
//  ContentView.swift
//  time Watch App
//
//  Created by Show on 2024/9/28.
//

import SwiftUI

struct ContentView: View {
    @State private var minutes: Int = 25
    @State private var showingFocusItems = false
    
    var body: some View {
        VStack {
            Text("番茄鐘")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 10)
            
            Spacer()
            
            HStack(spacing: 30) {
                Button(action: {
                    if minutes > 1 {
                        minutes -= 1
                    }
                }) {
                    Text("-")
                }
                .buttonStyle(CircleButtonStyle())
                
                Text("\(minutes)")
                    .font(.system(size: 40, weight: .bold))
                
                Button(action: {
                    if minutes < 60 {
                        minutes += 1
                    }
                }) {
                    Text("+")
                }
                .buttonStyle(CircleButtonStyle())
            }
            
            Spacer()
            
            Button(action: {
                // 開始按鈕的動作 (暫時為空)
            }) {
                Text("開始")
            }
            .buttonStyle(StartButtonStyle())
            
            Button(action: {
                showingFocusItems = true
            }) {
                Text("選擇專注項目")
            }
            .buttonStyle(StartButtonStyle())
            .padding(.bottom, 10)
        }
        .sheet(isPresented: $showingFocusItems) {
            FocusItemsView()
        }
    }
}

struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .frame(width: 44, height: 44)
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .clipShape(Circle())
    }
}

struct StartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.green.opacity(0.8) : Color.green)
            .cornerRadius(25)
    }
}

#Preview {
    ContentView()
}
