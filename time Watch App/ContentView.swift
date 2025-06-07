//
//  ContentView.swift
//  time Watch App
//
//  Created by Show on 2024/9/28.
//

import SwiftUI

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

struct BackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20))
            .foregroundColor(.white)
            .frame(width: 35, height: 35)
            .background(Color.black.opacity(0.3))
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

struct FocusItem: Identifiable, Codable {
    let id = UUID()
    let name: String
}

struct ContentView: View {
    @AppStorage("defaultMinutes") private var defaultMinutes = 25
    @AppStorage("defaultFocusItems") private var defaultFocusItems = 1
    @AppStorage("focusItems") private var focusItemsData: Data = Data()
    @State private var minutes: Int
    @State private var numberOfFocusItems: Int
    @State private var showingFocusItems = false
    @State private var showingTimer = false
    @State private var selectedItems: [String] = [] // 改為空陣列，不預設選擇
    @State private var showingSettings = false
    @State private var focusItems: [FocusItem] = []
    @State private var availableTimerItems: [TimerItem] = []
    @State private var isInitialized = false
    
    // 用於調試
    @State private var errorMessage: String = ""
    
    private let timerManager = TimerManager.shared

    init() {
        let savedMinutes = UserDefaults.standard.integer(forKey: "defaultMinutes")
        let savedFocusItems = UserDefaults.standard.integer(forKey: "defaultFocusItems")
        _minutes = State(initialValue: savedMinutes > 0 ? savedMinutes : 25)
        _numberOfFocusItems = State(initialValue: savedFocusItems > 0 ? savedFocusItems : 1)
    }

    private func loadFocusItems() {
        // 從資料庫載入項目
        availableTimerItems = timerManager.getAllItems()
        
        // 標記為已初始化，但不自動選擇項目
        isInitialized = true
        
        print("載入項目完成，可用項目數：\(availableTimerItems.count)，已選項目：\(selectedItems)")
    }
    
    private func ensureSelectedItems() {
        // 移除自動選擇邏輯，只保留數量限制邏輯
        if selectedItems.count > numberOfFocusItems {
            selectedItems = Array(selectedItems.prefix(numberOfFocusItems))
        }
        
        print("ensureSelectedItems 完成，當前選中項目：\(selectedItems)")
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 20))
                }
                .buttonStyle(BackButtonStyle())

                Spacer()

                Text("番茄鐘")
                    .font(.system(size: 25, weight: .bold))

                Spacer()

                Circle()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 2) {
                Text("專注時間")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack(spacing: 15) {
                    Button(action: {
                        if minutes > 1 {
                            minutes -= 1
                        }
                    }) {
                        Image(systemName: "minus")
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
                        Image(systemName: "plus")
                    }
                    .buttonStyle(CircleButtonStyle())
                }
            }
            .padding(.vertical, 3)

            VStack(spacing: 2) {
                Text("專注項目數量")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack(spacing: 15) {
                    Button(action: {
                        if numberOfFocusItems > 1 {
                            numberOfFocusItems -= 1
                            // 確保初始化完成後才執行
                            if isInitialized {
                                ensureSelectedItems()
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(CircleButtonStyle())
                    Text("\(numberOfFocusItems)")
                        .font(.system(size: 25, weight: .bold))
                        .frame(width: 35)
                    Button(action: {
                        if numberOfFocusItems < 9 {
                            numberOfFocusItems += 1
                            // 不再自動填充選擇項目
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(CircleButtonStyle())
                }
            }
            .padding(.vertical, 3)
            


            // 顯示錯誤訊息
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: {
                    // 確保已初始化
                    if !isInitialized {
                        loadFocusItems()
                    }
                    
                    // 檢查是否已選擇專注項目
                    if selectedItems.isEmpty {
                        errorMessage = "請先選擇專注項目"
                        showingFocusItems = true // 直接開啟選擇畫面
                        return
                    }
                    
                    // 檢查選擇數量是否符合設定
                    if selectedItems.count != numberOfFocusItems {
                        errorMessage = "請選擇 \(numberOfFocusItems) 個專注項目"
                        showingFocusItems = true
                        return
                    }
                    
                    errorMessage = ""
                    print("開始計時，選中項目：\(selectedItems)")
                    showingTimer = true
                }) {
                    Text("開始")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SideButtonStyle())
                .frame(minHeight: 40)

                Button(action: {
                    errorMessage = "" // 清除錯誤訊息
                    showingFocusItems = true
                }) {
                    Text("項目")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SideButtonStyle())
                .frame(minHeight: 40)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 10)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingFocusItems) {
            FocusItemsView(
                maxSelections: numberOfFocusItems,
                selectedItems: $selectedItems
            )
        }
        .fullScreenCover(isPresented: $showingTimer) {
            TimerView(
                selectedItems: selectedItems,
                minutes: minutes
            )
        }
        .onChange(of: numberOfFocusItems) { newValue in
            // 只有在初始化完成後才執行
            if isInitialized {
                ensureSelectedItems()
                print("專注項目數量改變為 \(newValue)，當前選中項目：\(selectedItems)")
            }
        }
        .onChange(of: selectedItems) { newValue in
            // 當選擇項目改變時，清除錯誤訊息
            if !newValue.isEmpty {
                errorMessage = ""
            }
        }
        .onAppear {
            // 只在第一次出現時載入
            if !isInitialized {
                loadFocusItems()
            }
            print("ContentView onAppear - 選中項目: \(selectedItems), 初始化狀態: \(isInitialized)")
        }
    }
}

#Preview {
    ContentView()
}
