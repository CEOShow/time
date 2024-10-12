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
    @State private var numberOfFocusItems: Int = 1
    @State private var showingTimer = false
    @State private var selectedItems: [String] = []
    
    private let focusItems = [
        FocusItem(name: "讀書"),
        FocusItem(name: "做家事"),
        FocusItem(name: "玩電動"),
        FocusItem(name: "唸英文"),
        FocusItem(name: "寫程式"),
        FocusItem(name: "畫畫"),
        FocusItem(name: "運動"),
        FocusItem(name: "冥想"),
        FocusItem(name: "寫作")
    ]

    var body: some View {
        VStack(spacing: 8) {
            Text("番茄鐘")
                .font(.system(size: 25, weight: .bold))
                .padding(.top, 5)

            Spacer()

            // 時間選擇器
            VStack(spacing: 2) {
                Text("專注時間")
                    .font(.subheadline)

                HStack(spacing: 15) {
                    Button(action: {
                        if minutes > 1 {
                            minutes -= 1
                        }
                    }) {
                        Text("-")
                    }
                    .buttonStyle(CircleButtonStyle())

                    Text("\(minutes)")
                        .font(.system(size: 25, weight: .bold))
                        .frame(width: 35)

                    Button(action: {
                        if minutes < 60 {
                            minutes += 1
                        }
                    }) {
                        Text("+")
                    }
                    .buttonStyle(CircleButtonStyle())
                }
            }
            .padding(.vertical, 3)

            // 專注項目數量選擇器
            VStack(spacing: 2) {
                Text("專注項目數量")
                    .font(.subheadline)

                HStack(spacing: 15) {
                    Button(action: {
                        if numberOfFocusItems > 1 {
                            numberOfFocusItems -= 1
                        }
                    }) {
                        Text("-")
                    }
                    .buttonStyle(CircleButtonStyle())

                    Text("\(numberOfFocusItems)")
                        .font(.system(size: 25, weight: .bold))
                        .frame(width: 35)

                    Button(action: {
                        if numberOfFocusItems < 9 {
                            numberOfFocusItems += 1
                        }
                    }) {
                        Text("+")
                    }
                    .buttonStyle(CircleButtonStyle())
                }
            }
            .padding(.vertical, 3)

            Spacer()

            // 底部按鈕並排
            HStack(spacing: 8) {
                Button(action: {
                    if !selectedItems.isEmpty {
                        showingTimer = true
                    }
                }) {
                    Text("開始")
                }
                .buttonStyle(SideButtonStyle())
                .disabled(selectedItems.isEmpty)

                Button(action: {
                    showingFocusItems = true
                }) {
                    Text("項目")
                }
                .buttonStyle(SideButtonStyle())
            }
            .padding(.bottom, 5)
        }
        .sheet(isPresented: $showingFocusItems) {
            FocusItemsView(
                focusItems: focusItems,
                maxSelections: numberOfFocusItems,
                selectedItems: $selectedItems
            )
        }
        .fullScreenCover(isPresented: $showingTimer) {
            TimerView(
                selectedItem: selectedItems.first ?? "",  // 防止越界
                minutes: minutes
            )
        }
    }
}

struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18))
            .frame(width: 30, height: 30)
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .clipShape(Circle())
    }
}

struct SideButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(height: 35)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.green.opacity(0.8) : Color.green)
            .cornerRadius(17.5)
            .padding(.horizontal, 5)
    }
}




#Preview {
    ContentView()
}
