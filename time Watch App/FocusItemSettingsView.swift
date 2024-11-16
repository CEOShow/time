//
//  FocusItemSettingsView.swift
//  time Watch App
//
//  Created by Show on 2024/11/9.
//

import SwiftUI

struct FocusItemSettingsView: View {
    @AppStorage("focusItems") private var focusItemsData: Data = Data()
    @State private var items: [String] = []
    @State private var isEditing = false
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                        .padding(.vertical, 2)
                    Spacer()
                    if isEditing {
                        Button(action: {
                            if let index = items.firstIndex(of: item) {
                                items.remove(at: index)
                                saveItems()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            if isEditing {
                Button(action: {
                    showingAddItem = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("新增項目")
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
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
        .alert("新增專注項目", isPresented: $showingAddItem) {
            TextField("項目名稱", text: $newItemName)
            Button("取消", role: .cancel) {}
            Button("新增") {
                if !newItemName.isEmpty {
                    items.append(newItemName)
                    saveItems()
                    newItemName = ""
                }
            }
        }
        .onAppear {
            loadItems()
        }
    }
    
    private func loadItems() {
        if let savedItems = try? JSONDecoder().decode([String].self, from: focusItemsData) {
            items = savedItems
        } else {
            // 預設項目
            items = [
                "讀書",
                "做家事",
                "玩電動",
                "唸英文",
                "寫程式",
                "畫畫",
                "運動",
                "冥想",
                "寫作"
            ]
            saveItems()
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            focusItemsData = encoded
        }
    }
}

#Preview {
    NavigationStack {
        FocusItemSettingsView()
    }
}
