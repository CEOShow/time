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
    @State private var selectedItems: [String] = []
    @State private var showingSettings = false
    @State private var focusItems: [FocusItem] = []
    
    init() {
        let savedMinutes = UserDefaults.standard.integer(forKey: "defaultMinutes")
        let savedFocusItems = UserDefaults.standard.integer(forKey: "defaultFocusItems")
        _minutes = State(initialValue: savedMinutes > 0 ? savedMinutes : 25)
        _numberOfFocusItems = State(initialValue: savedFocusItems > 0 ? savedFocusItems : 1)
    }
    
    private func loadFocusItems() {
        if let savedItems = try? JSONDecoder().decode([FocusItem].self, from: focusItemsData) {
            focusItems = savedItems
        } else {
            focusItems = [
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
            if let encoded = try? JSONEncoder().encode(focusItems) {
                focusItemsData = encoded
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
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
            .padding(.top, 5)

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
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(CircleButtonStyle())
                }
            }
            .padding(.vertical, 3)

            Spacer()

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
            if selectedItems.count > newValue {
                selectedItems = Array(selectedItems.prefix(newValue))
            }
        }
        .onAppear {
            loadFocusItems()
        }
    }
}

#Preview {
    ContentView()
}
