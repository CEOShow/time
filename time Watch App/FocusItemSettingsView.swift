//
//  FocusItemSettingsView.swift
//  time Watch App
//
//  Created by Show on 2024/11/9.
//

import SwiftUI

struct FocusItemSettingsView: View {
    @State private var items: [TimerItem] = []
    @State private var isEditing = false
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    // 使用 TimerManager 單例
    private let timerManager = TimerManager.shared

    var body: some View {
        List {
            ForEach(items) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    if isEditing {
                        Button(action: {
                            if timerManager.deleteItem(id: item.id) {
                                loadItems()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }

            if isEditing {
                Button(action: { showingAddItem = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("新增項目")
                    }
                }
            }
        }
        .navigationTitle("專注項目")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "完成" : "編輯") {
                    withAnimation {
                        isEditing.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            NavigationStack {
                Form {
                    TextField("項目名稱", text: $newItemName)
                }
                .navigationTitle("新增專注項目")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showingAddItem = false
                            newItemName = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("新增") {
                            if !newItemName.isEmpty {
                                if timerManager.addItem(name: newItemName) {
                                    loadItems()
                                    newItemName = ""
                                    showingAddItem = false
                                } else {
                                    print("Failed to save new item")
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear { loadItems() }
    }

    private func loadItems() {
        items = timerManager.getAllItems()
        if items.isEmpty {
            let defaultItems = ["讀書", "運動", "冥想"]
            for item in defaultItems {
                _ = timerManager.addItem(name: item)
            }
            items = timerManager.getAllItems()
        }
    }
}

#Preview {
    NavigationStack {
        FocusItemSettingsView()
    }
}
