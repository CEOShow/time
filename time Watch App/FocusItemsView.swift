//
//  FocusItemsView.swift
//  time Watch App
//
//  Created by Show on 2024/9/28.
//

import SwiftUI

struct FocusItem: Identifiable {
    let id = UUID()
    let name: String
}

struct FocusItemsView: View {
    @State private var focusItems = [
        FocusItem(name: "讀書"),
        FocusItem(name: "做家事"),
        FocusItem(name: "玩電動"),
        FocusItem(name: "唸英文")
    ]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("請選擇專注項目")
                .font(.headline)
                .padding()
            
            List {
                ForEach(focusItems) { item in
                    Text(item.name)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
    }
}

#Preview {
    FocusItemsView()
}
