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
    @State private var loadedFocusItems: [FocusItem] = []
    let maxSelections: Int
    @Binding var selectedItems: [String]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("選擇 \(maxSelections) 個專注項目")
                    .font(.headline)
                    .padding(.top)
                
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 2),
                        spacing: 10
                    ) {
                        ForEach(loadedFocusItems) { item in
                            SelectableButton(
                                text: item.name,
                                isSelected: selectedItems.contains(item.name),
                                action: {
                                    if selectedItems.contains(item.name) {
                                        selectedItems.removeAll { $0 == item.name }
                                    } else {
                                        if selectedItems.count < maxSelections {
                                            selectedItems.append(item.name)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                Button("確定") {
                    dismiss()
                }
                .buttonStyle(SideButtonStyle())
                .padding()
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
        if let savedItems = try? JSONDecoder().decode([FocusItem].self, from: focusItemsData) {
            loadedFocusItems = savedItems
        }
    }
}

struct SelectableButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
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
