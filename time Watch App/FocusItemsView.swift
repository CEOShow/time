//
//  FocusItemsView.swift
//  time Watch App
//
//  Created by Show on 2024/9/28.
//

import SwiftUI
import Foundation

// FocusItemsView 用於顯示專注項目的選擇
struct FocusItemsView: View {
    let focusItems: [FocusItem]
    let maxSelections: Int
    @Binding var selectedItems: [String]

    var body: some View {
        List(focusItems) { item in
            Button(action: {
                if selectedItems.contains(item.name) {
                    selectedItems.removeAll { $0 == item.name }
                } else if selectedItems.count < maxSelections {
                    selectedItems.append(item.name)
                }
            }) {
                HStack {
                    Text(item.name)
                    Spacer()
                    if selectedItems.contains(item.name) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
