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
    let maxSelections: Int
    @Binding var selectedItems: [String]

    var body: some View {
        List(focusItems) { item in
            Button(action: {
                toggleSelection(item: item)
            }) {
                HStack {
                    Text(item.name)
                    Spacer()
                    if let index = selectedItems.firstIndex(of: item.name) {
                        Text("\(index + 1)")
                            .foregroundColor(.blue)
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.blue.opacity(0.2)))
                    }
                }
            }
        }
        .onChange(of: maxSelections) { newValue in
            updateSelectedItems(newMaxSelections: newValue)
        }
    }
    
    private func toggleSelection(item: FocusItem) {
        if let index = selectedItems.firstIndex(of: item.name) {
            selectedItems.remove(at: index)
        } else if selectedItems.count < maxSelections {
            selectedItems.append(item.name)
        }
    }
    
    private func updateSelectedItems(newMaxSelections: Int) {
        if selectedItems.count > newMaxSelections {
            selectedItems = Array(selectedItems.prefix(newMaxSelections))
        }
    }
}
