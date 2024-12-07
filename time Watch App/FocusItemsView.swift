//
//  FocusItemsView.swift
//  time Watch App
//
//  Created by Show on 2024/9/28.
//

import SwiftUI

struct FocusItemsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("focusItems") private var focusItemsData: Data = Data()
    @State private var loadedFocusItems: [FocusItemModel] = []
    let maxSelections: Int
    @Binding var selectedItems: [String]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("選擇 \(maxSelections) 個專注項目")
                    .font(.headline)
                    .padding(.top)
                List {
                    ForEach(loadedFocusItems, id: \.id) { item in
                        SelectableListRow(
                            text: item.name,
                            isSelected: selectedItems.contains(item.name),
                            action: {
                                toggleSelection(for: item.name)
                            }
                        )
                    }
                    
                    Button("確定") {
                        dismiss()
                    }
                    .buttonStyle(SideButtonStyle())
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listStyle(PlainListStyle()) // 使用 PlainListStyle 以便於 watchOS 兼容
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
        }
    }
    
    private func loadItems() {
        if let savedItems = try? JSONDecoder().decode([FocusItemModel].self, from: focusItemsData) {
            loadedFocusItems = savedItems
        }
    }
    
    private func toggleSelection(for itemName: String) {
        if selectedItems.contains(itemName) {
            selectedItems.removeAll { $0 == itemName }
        } else if selectedItems.count < maxSelections {
            selectedItems.append(itemName)
        } else {
            // 如果已經達到最大選擇數量,則取消第一個選擇的項目
            selectedItems.removeFirst()
            selectedItems.append(itemName)
        }
    }
}

struct SelectableListRow: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.clear)
            .cornerRadius(8)
        }
    }
}

struct FocusItemModel: Identifiable, Codable {
    let id: UUID
    let name: String
}

struct FocusItemsView_Previews: PreviewProvider {
    static var previews: some View {
        FocusItemsView(
            maxSelections: 2,
            selectedItems: .constant(["讀書"])
        )
    }
}
