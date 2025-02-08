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
        }
    }
    
    private func loadItems() {
        loadedFocusItems = timerManager.getAllItems()
    }
    
    private func toggleSelection(for itemName: String) {
        if selectedItems.contains(itemName) {
            selectedItems.removeAll { $0 == itemName }
        } else if selectedItems.count < maxSelections {
            selectedItems.append(itemName)
        } else {
            selectedItems.removeFirst()
            selectedItems.append(itemName)
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
                }
            }
            .padding()
            .background(Color.clear)
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
