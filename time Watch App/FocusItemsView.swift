//
//  FocusItemsView.swift
//  time Watch App
//
//  Created by Show on 2024/9/28.
//

import SwiftUI
import Foundation

struct FocusItemsView: View {
    let focusItems: [FocusItem]
    @State private var selectedItems: [UUID: Int] = [:]
    let maxSelections: Int
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("請選擇\(maxSelections)個專注項目")
                .font(.subheadline)
                .padding(.top, 5)
            
            List {
                ForEach(focusItems) { item in
                    Button(action: {
                        toggleSelection(for: item)
                    }) {
                        HStack {
                            Text(item.name)
                            Spacer()
                            if let order = selectedItems[item.id] {
                                Text("\(order)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("完成")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(height: 35)
                        .frame(maxWidth: .infinity)
                        .background(selectedItems.count == maxSelections ? Color.green : Color.gray)
                        .cornerRadius(17.5)
                }
                .disabled(selectedItems.count != maxSelections)  // 只有在選擇的數量等於要求的數量時才能點擊
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
    }
    
    private func toggleSelection(for item: FocusItem) {
        if let _ = selectedItems[item.id] {
            selectedItems.removeValue(forKey: item.id)
            reorderSelections()
        } else {
            if selectedItems.count < maxSelections {
                selectedItems[item.id] = selectedItems.count + 1
            }
        }
    }
    
    private func reorderSelections() {
        var order = 1
        var newSelections: [UUID: Int] = [:]
        
        for id in selectedItems.keys.sorted(by: { selectedItems[$0]! < selectedItems[$1]! }) {
            newSelections[id] = order
            order += 1
        }
        
        selectedItems = newSelections
    }
}
