//
//  FocusItemsView.swift
//  time Watch App
//
//  Created by Show on 2024/9/28.
//

import SwiftUI

struct FocusItemsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var loadedFocusItems: [TimerItem] = []
    let maxSelections: Int
    @Binding var selectedItems: [String]
    
    private let timerManager = TimerManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("選擇 \(maxSelections) 個專注項目")
                    .font(.headline)
                    .padding(.top)
                
                // 顯示已選項目計數
                Text("已選擇 \(selectedItems.count)/\(maxSelections) 項")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.bottom, 5)
                
                List {
                    ForEach(loadedFocusItems) { item in
                        SelectableListRow(
                            text: item.name,
                            isSelected: selectedItems.contains(item.name),
                            selectionIndex: selectedItems.firstIndex(of: item.name).map { $0 + 1 },
                            action: {
                                toggleSelection(for: item.name)
                            }
                        )
                    }
                    
                    Button("確定") {
                        print("確認選擇，當前選擇項目: \(selectedItems)")
                        dismiss()
                    }
                    .buttonStyle(SideButtonStyle())
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("專注項目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadItems()
            print("FocusItemsView出現，當前選擇: \(selectedItems)")
        }
        .onDisappear {
            print("FocusItemsView消失，選中項目: \(selectedItems)")
        }
    }
    
    private func loadItems() {
        loadedFocusItems = timerManager.getAllItems()
        
        // 如果資料庫中沒有項目，加入預設項目
        if loadedFocusItems.isEmpty {
            let defaultItems = ["讀書", "做家事", "玩電動", "唸英文", "寫程式", "畫畫", "運動", "冥想", "寫作"]
            for item in defaultItems {
                _ = timerManager.addItem(name: item)
            }
            loadedFocusItems = timerManager.getAllItems()
        }
    }
    
    private func toggleSelection(for itemName: String) {
        if selectedItems.contains(itemName) {
            // 如果已選中，則移除
            selectedItems.removeAll { $0 == itemName }
            print("取消選擇: \(itemName), 當前選擇: \(selectedItems)")
        } else if selectedItems.count < maxSelections {
            // 如果未達到最大選擇數，直接添加
            selectedItems.append(itemName)
            print("添加選擇: \(itemName), 當前選擇: \(selectedItems)")
        } else {
            // 如果已達到最大選擇數，移除第一個並添加新的
            if !selectedItems.isEmpty {
                let removed = selectedItems.removeFirst()
                print("移除最舊選擇: \(removed)")
            }
            selectedItems.append(itemName)
            print("添加新選擇: \(itemName), 當前選擇: \(selectedItems)")
        }
    }
}

struct SelectableListRow: View {
    let text: String
    let isSelected: Bool
    let selectionIndex: Int?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                if let index = selectionIndex {
                    Text("\(index)")
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .semibold))
                } else if isSelected {
                    // 這行可以移除，因為已經有index顯示了
                    // 但如果出現邏輯錯誤，至少能顯示選中狀態
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
    }
}

struct FocusItemsView_Previews: PreviewProvider {
    static var previews: some View {
        FocusItemsView(
            maxSelections: 2,
            selectedItems: .constant(["讀書"])
        )
    }
}
