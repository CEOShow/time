//
//  FocusItemSettingsView.swift
//  time Watch App
//
//  Created by Show on 2024/11/9.
//

import SwiftUI

struct FocusItemSettingsView: View {
    @AppStorage("focusItems") private var focusItemsData: Data = Data()
    @State private var items: [FocusItem] = []
    @State private var isEditing = false
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    var body: some View {
        List {
            ForEach(items) { item in
                HStack {
                    Text(item.name)
                        .padding(.vertical, 2)
                    Spacer()
                    if isEditing {
                        Button(action: {
                            if let index = items.firstIndex(where: { $0.id == item.id }) {
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
                                let newItem = FocusItem(name: newItemName)
                                items.append(newItem)
                                saveItems()
                                newItemName = ""
                                showingAddItem = false
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadItems()
        }
    }
    
    private func loadItems() {
        if let savedItems = try? JSONDecoder().decode([FocusItem].self, from: focusItemsData) {
            items = savedItems
        } else {
            items = [
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
